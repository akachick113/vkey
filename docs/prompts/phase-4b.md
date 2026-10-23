# Phase 4b — Ký đủ bản Release, quy trình phát hành, kiểm cập nhật thật (cục bộ)

> Codex · **GPT-6 Sol** · effort **Medium** (script + một module Python thuần có test + tài liệu, đã đo trước cách ký; phần
> khó là kịch bản chạy thật nhiều bước — Luna dễ bỏ bước — WORKFLOW §8) · nhánh `phase-4b-release-pipeline`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Quyết định chung**, Phase 4: quyết định người dùng chốt 2026-10-22, **✅ 4a xong** —
Quyết định đã chốt + Còn tồn), `docs/UPDATES.md`, `docs/reviews/phase-4a.md` (mục Chạy thật (e), (f)).

Mục tiêu:
1. **Việc 0 — C1 (còn tồn 4a):** bản Release phát hành không còn thành phần nào ký ad-hoc: 4 helper Sparkle ký lại bằng
   Apple Development team `8C4YAMZSGP`; `scripts/notarize.sh` (identity / profile của chủ repo gốc) thay bằng script ký
   của dự án này; `docs/UPDATES.md` mục "Tạo bản phát hành" viết lại cho bản JIS.
2. Chuẩn bị bản phát hành đầu tiên **MKey JIS 1.7.0 (build 14)** và kiểm **cập nhật thật** bản cũ → mới bằng feed cục bộ
   (relaunch, quyền Trợ năng giữ nguyên).

Người dùng chốt 2026-10-22:

| Mục | Giá trị |
|---|---|
| Version / build đầu tiên | `1.7.0` / `14` (origin có sẵn tag `v1.0.0`…`v1.6.1` của mkey gốc → không dùng lại 1.6.1) |
| Repo `akachick113/mkey-jis` | **vẫn private** trong 4b. Không public, không tag, không GitHub Release, không upload — để sau khi 4b merge |
| Upload Release (về sau) | người dùng làm qua web github.com (máy không có `gh`) |
| Kiểm cập nhật | **feed cục bộ** `http://127.0.0.1` ký bằng khoá Sparkle thật; kiểm feed GitHub thật để sau khi public |

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; Conventional Commits tiếng Việt; chỉ `git add <file>`; **mở PR
vào `main` của `origin`** và gửi link. Ca test mới đánh số từ **65**.

### Hiện trạng đã xem (Claude, `origin/main` @ `9b693c7`, máy JIS này, 2026-10-22)
- **Build Release universal** chạy được: `xcodebuild -project mkey.xcodeproj -scheme mkey -configuration Release
  -derivedDataPath build/DerivedData ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO build` → `lipo -archs` = `x86_64 arm64` cho
  app và cả Sparkle. Không cần provisioning profile, Keychain không hỏi.
- **Chữ ký của bản build đó** (`codesign -dv --verbose=2`, entitlements bằng `codesign -d --entitlements - --xml`):

  | Thành phần (trong `mkey-jis.app`) | Chữ ký | Entitlements |
  |---|---|---|
  | app | team `8C4YAMZSGP`, `flags=0x10000(runtime)`, có `Timestamp` | rỗng |
  | `Contents/Frameworks/Sparkle.framework` | team, runtime, Timestamp | — |
  | `…/Versions/B/Autoupdate` | **`Signature=adhoc`**, `flags=0x10002(adhoc,runtime)`, `TeamIdentifier=not set`, `Identifier=Autoupdate-5555494467dcbc6056da3300b22db5f67fff8b2d` | `com.apple.application-identifier` = `org.sparkle-project.Sparkle.Autoupdate` |
  | `…/Versions/B/Updater.app` | **adhoc** (`org.sparkle-project.Sparkle.Updater`) | rỗng |
  | `…/Versions/B/XPCServices/Downloader.xpc` | **adhoc** (`org.sparkle-project.DownloaderService`) | rỗng |
  | `…/Versions/B/XPCServices/Installer.xpc` | **adhoc** (`org.sparkle-project.InstallerLauncher`) | rỗng |

  Designated requirement của app (TCC dùng để nhận ra app khi cấp quyền Trợ năng): `identifier
  "io.github.akachick113.mkeyjis" and anchor apple generic and certificate leaf[subject.CN] = "Apple Development:
  akachick113@gmail.com (BCHZ2Y26CN)" and certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */` → mọi bản ký bằng
  chứng chỉ cùng CN đều được coi là cùng một app.
- **Thử ký lại** trên bản sao (scratchpad), đúng thứ tự và cờ của `notarize.sh`: `Downloader.xpc`, `Installer.xpc`,
  `Autoupdate`, `Updater.app`, `Sparkle.framework`, app — mỗi cái `codesign --force --sign "Apple Development:
  akachick113@gmail.com (BCHZ2Y26CN)" --options runtime --timestamp --preserve-metadata=identifier,entitlements`. Kết quả:
  cả 6 thành phần team `8C4YAMZSGP`, `flags=0x10000(runtime)`, có `Timestamp`; entitlement của `Autoupdate` giữ nguyên;
  `codesign --verify --deep --strict` → `valid on disk` + `satisfies its Designated Requirement`; DR của app không đổi.
  Chạy thẳng `Autoupdate` đã ký lại (không tham số) → thoát mã 1 như bản ad-hoc (không bị AMFI giết vì entitlement).
  Trích `codesign -dv --verbose=2` thật (dùng làm mẫu cho test):
  ```text
  # app sau khi ký lại
  Identifier=io.github.akachick113.mkeyjis
  Format=app bundle with Mach-O universal (x86_64 arm64)
  CodeDirectory v=20500 size=2377 flags=0x10000(runtime) hashes=63+7 location=embedded
  Signature size=9097
  Authority=Apple Development: akachick113@gmail.com (BCHZ2Y26CN)
  Authority=Apple Worldwide Developer Relations Certification Authority
  Authority=Apple Root CA
  Timestamp=Oct 22, 2026 at 11:32:12
  Info.plist entries=35
  TeamIdentifier=8C4YAMZSGP

  # Autoupdate trước khi ký lại
  Identifier=Autoupdate-5555494467dcbc6056da3300b22db5f67fff8b2d
  Format=Mach-O universal (x86_64 arm64)
  CodeDirectory v=20500 size=1044 flags=0x10002(adhoc,runtime) hashes=21+7 location=embedded
  Signature=adhoc
  Info.plist=not bound
  TeamIdentifier=not set
  ```
  (`codesign -dv` in ra **stderr**. Framework / xpc có `Format=bundle with Mach-O universal (x86_64 arm64)`.)
- **`scripts/notarize.sh`**: copy app → ký 6 thành phần như trên → `notarytool` (profile `MFinderNotary`) → `stapler` →
  `spctl` → zip `mkey-<version>-notarized.zip`; identity mặc định `Developer ID Application: Anh Tuan Vu Nguyen
  (CF5PGH3KGK)`, output `"$OUTPUT/mkey.app"` (tên cũ). Không dùng được cho dự án này (không Developer ID, không notarize).
- **`scripts/build-update-feed.sh`** (đã trỏ repo mới ở 4a): `codesign --verify --deep --strict` (`:18`) — **không** phát hiện
  helper ad-hoc (bản build thô vẫn pass); kiểm Info.plist; zip bằng `ditto -c -k --sequesterRsrc --keepParent`;
  `generate_appcast --download-url-prefix … --maximum-versions 5 --maximum-deltas 0`; `verify-update-feed.py`.
- **Khoá Sparkle trong Keychain chỉ mở được cho công cụ Sparkle ở checkout chính**:
  `/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin` (bản người dùng dùng để tạo
  khoá) chạy `generate_appcast` / `sign_update` không hỏi gì. Cùng công cụ ở thư mục khác (worktree) → Keychain bật hộp
  thoại hỏi quyền và lệnh treo. **Luôn truyền đường dẫn bin ở checkout chính**; nếu hộp thoại Keychain vẫn hiện → dừng,
  nhờ người dùng xử lý, không tự bấm.
- **Feed cục bộ** dựng được: `generate_appcast --account io.github.akachick113.mkeyjis --download-url-prefix
  http://127.0.0.1:8765/ --release-notes-url-prefix http://127.0.0.1:8765/ --maximum-deltas 0 <thư mục có zip + md>` →
  enclosure `http://127.0.0.1:8765/mkey-jis-<v>.zip` có `sparkle:edSignature`; `sign_update --verify --account …
  appcast.xml` pass. `generate_appcast` **sửa file `.md`** trong thư mục (thêm dòng cảnh báo ký) → luôn chép notes vào thư
  mục làm việc, không trỏ thẳng file trong repo. `tests/run-update-smoke.py` đã chứng minh app có
  `NSAppTransportSecurity.NSAllowsLocalNetworking` đọc được feed `http://127.0.0.1`.
- **Cập nhật chỉ chạy khi app nằm trực tiếp trong `/Applications`** (`UpdateRuntimePolicy.swift:17`). Menu "Kiểm tra cập
  nhật…" ở `MkeyApp.swift:74` (menu bar) và `:130`. Hiện `/Applications` không có `mkey-jis.app`.
- **Version** trong `Sources/Support/Info.plist`: `CFBundleShortVersionString` `1.6.1` (`:22`), `CFBundleVersion` `13`
  (`:24`). Ghi chú phát hành của mkey gốc có sẵn ở `docs/releases/1.6.1.md` (quy ước `docs/releases/<version>.md`).
- **Chứng chỉ**: duy nhất `Apple Development: akachick113@gmail.com (BCHZ2Y26CN)`, `OU=8C4YAMZSGP`, hết hạn
  **2027-08-11**.
- **Tài liệu**: `docs/UPDATES.md:27-87` (mục "Tạo bản phát hành") còn quy trình notarize + đoạn tạm của 4a; `:83-84` nói
  "chuyển từ ad-hoc sang Developer ID"; `:104-106` "kiểm tra thêm trên bản đã notarize". `README.md:98-99` có câu "(quy
  trình bản JIS sẽ hoàn thiện ở Phase 4b)" và "Bản cũ chưa có Sparkle…".

## Việc 0 — Còn tồn 4a

### C1a — Kiểm chữ ký bản phát hành: `scripts/verify-release-signature.py` (mới)
Python 3 chỉ dùng thư viện chuẩn, cùng kiểu `verify-update-feed.py` (docstring đầu file, `argparse`, chú thích tiếng Anh).
- Hằng `COMPONENTS` — đường dẫn tương đối trong app, theo thứ tự ký:
  `Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc`, `…/XPCServices/Installer.xpc`,
  `…/Versions/B/Autoupdate`, `…/Versions/B/Updater.app`, `Contents/Frameworks/Sparkle.framework`, `.` (chính app).
- Hàm thuần (không gọi tiến trình, không đọc đĩa):
  ```python
  def signature_problems(details, team):
      """details: component -> `codesign -dv --verbose=2` text, or None if missing. Returns a list of problems."""
  ```
  Với từng mục của `COMPONENTS` (theo thứ tự), thêm một chuỗi lỗi bắt đầu bằng tên component nếu: thiếu (không có khoá
  hoặc `None`); có dòng `Signature=adhoc` hoặc cờ `adhoc` trong dòng `CodeDirectory … flags=…(…)`; dòng `TeamIdentifier=`
  khác `team`; cờ trong `flags=…(…)` không có `runtime`; không có dòng `Timestamp=`; riêng `.` — dòng `Format=` không chứa
  **cả** `x86_64` và `arm64`. Mọi thành phần hợp lệ → `[]`. Mỗi component có thể sinh nhiều lỗi.
- CLI: `scripts/verify-release-signature.py APP [--team 8C4YAMZSGP]` → chạy `codesign -dv --verbose=2` cho từng component
  (đọc stderr; component không tồn tại → `None`), gọi `signature_problems`, rồi `codesign --verify --deep --strict APP`. Có
  lỗi → in từng dòng ra stderr, thoát ≠ 0. Không lỗi → in
  `PASS: release signatures (6 components, team 8C4YAMZSGP, universal)`.

### C1b — Ký lại: `scripts/notarize.sh` → `scripts/sign-release.sh`
`git mv scripts/notarize.sh scripts/sign-release.sh`, rồi viết lại (giữ `set -euo pipefail`, chú thích tiếng Anh ngắn):
- `usage: sign-release.sh APP NEW_OUTPUT_DIR`; `IDENTITY="${MKEY_SIGNING_IDENTITY:-Apple Development: akachick113@gmail.com
  (BCHZ2Y26CN)}"`; từ chối nếu app không có / output đã tồn tại (như cũ).
- `ditto` app sang `"$OUTPUT/mkey-jis.app"` (app nguồn không bị sửa). Ký 6 thành phần theo đúng thứ tự và cờ của vòng lặp
  hiện có (`--force --sign "$IDENTITY" --options runtime --timestamp --preserve-metadata=identifier,entitlements`) — giữ
  chú thích "Signing only the enclosing framework does not replace its ad-hoc helper signatures…".
- Bỏ toàn bộ phần notarize / staple / `spctl` / zip. Cuối script: `"$SCRIPT_DIR/verify-release-signature.py" "$APP"` rồi
  `echo "Signed app ready: $APP"`.
- Không gọi `xcodebuild`, không đọc / ghi Keychain ngoài việc `codesign` dùng chứng chỉ.

### C1c — Chặn feed cho app còn ad-hoc: `scripts/build-update-feed.sh`
Ngay sau dòng `codesign --verify --deep --strict "$APP"` (`:18`), gọi
`"$SCRIPT_DIR/verify-release-signature.py" "$APP"` (dời dòng `SCRIPT_DIR=` lên trước nếu cần). Không đổi logic khác.
Hệ quả có chủ ý: build Release thô (helper ad-hoc) không còn dựng feed được — phải qua `sign-release.sh`.

### C1d — Tài liệu: `docs/UPDATES.md`
- Dòng `:3` bỏ "giống MFinder" (giữ "Sparkle 2.9.6"). Mục "Cấu hình" giữ, thêm một gạch: chứng chỉ Apple Development
  hết hạn **2027-08-11** — gia hạn trước bản phát hành kế; chứng chỉ mới cùng CN thì app đã cài vẫn coi là cùng app (DR
  ở Hiện trạng) (ghi "chưa kiểm — kiểm ở lần gia hạn đầu"); khi Keychain có cả chứng chỉ cũ lẫn mới cùng tên, `codesign`
  báo trùng → đặt `MKEY_SIGNING_IDENTITY` bằng SHA-1 của chứng chỉ mới (`security find-identity -v -p codesigning`).
- Viết lại **toàn bộ** mục "Tạo bản phát hành" (xoá đoạn tạm của 4a, mọi chữ `notarize`, `MFinderNotary`, `Developer ID`
  trừ câu "không có Developer ID, không notarize"). Thứ tự, mỗi bước có lệnh trong khối `bash`:
  1. **Chuẩn bị** (PR thường): tăng `CFBundleShortVersionString` + `CFBundleVersion` trong `Sources/Support/Info.plist`,
     viết `docs/releases/<version>.md`, merge vào `main`. Kiểm chứng chỉ còn hạn và khoá Sparkle khớp
     (`generate_keys --account io.github.akachick113.mkeyjis -p` = `SUPublicEDKey`).
  2. **Build** từ đúng commit trên `main` (worktree sạch / checkout chính không có thay đổi): `xcodegen generate` + lệnh
     Release universal ở Hiện trạng.
  3. **Ký**: `scripts/sign-release.sh build/DerivedData/Build/Products/Release/mkey-jis.app build/release-<version>`.
     Giải thích ngắn vì sao (helper Sparkle từ SwiftPM vẫn ad-hoc; Release không notarize nên chỉ ký, không staple).
  4. **Kiểm cập nhật cục bộ** bằng `scripts/prepare-local-update-test.sh` (Việc 2) — tóm tắt các bước của kịch bản (e).
  5. **Đóng gói + feed**: `scripts/build-update-feed.sh build/release-<version>/mkey-jis.app docs/releases/<version>.md
     build/update-<version> <bin Sparkle ở checkout chính>`; bản thứ hai trở đi tải `appcast.xml` đang phát hành về và
     truyền ở tham số thứ năm (giữ nội dung đoạn `:72-74` hiện có). Ghi chú: công cụ Sparkle phải chạy từ đúng thư mục
     đã được Keychain cho phép (Hiện trạng).
  6. **Phát hành** (người dùng, qua web): repo phải **public**; tạo tag `v<version>` trỏ đúng commit đã build và push
     (`git tag v<version> <commit> && git push origin v<version>`); GitHub → Releases → Draft a new release → chọn tag,
     tiêu đề `MKey JIS <version>`, nội dung = `docs/releases/<version>.md`, đính kèm đủ 3 file trong
     `build/update-<version>/` → **Publish release** (không prerelease; là latest). Giữ các câu cảnh báo hiện có (không
     công bố appcast trỏ file chưa upload, không sửa file sau khi ký).
  7. **Kiểm sau phát hành**: `curl -fsSL -o /tmp/appcast.xml
     https://github.com/akachick113/mkey-jis/releases/latest/download/appcast.xml` + `sign_update --verify --account …
     /tmp/appcast.xml`; `curl -fsSIL` URL zip → 200; tải zip bằng trình duyệt, cài theo README (có bước "Vẫn mở"); menu
     "Kiểm tra cập nhật…" báo đã mới nhất.
- Đoạn `:81-84`: thay câu "chuyển từ chữ ký ad-hoc sang Developer ID…" bằng: MKey JIS có bundle id riêng nên **không** nhận
  cập nhật từ mkey gốc và ngược lại — người dùng mkey gốc cài MKey JIS bằng tay một lần (README); các bản MKey JIS sau
  cập nhật trong app, quyền Trợ năng giữ nguyên khi cùng chứng chỉ.
- Mục "Kiểm thử": thêm lệnh `python3 tests/release-signature-tests.py`; đoạn `:104-106` thay "trên bản đã notarize" bằng
  "bằng `scripts/prepare-local-update-test.sh` (bước 4)"; giữ câu "không suy ra việc cài/relaunch từ việc đọc feed thành công".
- `README.md:98-99`: bỏ "(quy trình bản JIS sẽ hoàn thiện ở Phase 4b)" và câu "Bản cũ chưa có Sparkle cần cài bản hỗ trợ
  lần đầu." (MKey JIS không có bản cũ chưa có Sparkle). Phần khác của README giữ.

## Việc 1 — Version 1.7.0 (build 14) + ghi chú phát hành
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` `1.7.0`, `CFBundleVersion` `14`. Không đổi khoá nào khác.
- `docs/releases/1.7.0.md` (mới; `docs/releases/1.6.1.md` của mkey gốc giữ nguyên), tiếng Việt, cùng giọng file 1.6.1:
  `# MKey JIS 1.7.0`; đoạn mở: bản đầu tiên của MKey JIS — mkey 1.6.1 (link `maclifevn/mkey`) mở rộng cho bàn phím JIS +
  bộ gõ tiếng Nhật của macOS; `## Khác gì mkey gốc` — chép 4 gạch đầu dòng từ mục cùng tên trong `README.md`;
  `## Cài đặt` — tóm tắt README "Cài đặt & cấp quyền" bước 1–5 (gỡ mkey gốc + prototype IMK, `mkey-jis-1.7.0.zip` →
  `/Applications`, **chưa notarize** → "Vẫn mở" / `xattr`, cấp Trợ năng cho **MKey JIS**), dòng "Hỗ trợ **Apple Silicon và
  Intel**, yêu cầu **macOS 14 trở lên**."; lưu ý cài đặt bắt đầu từ mặc định (không lấy cài đặt mkey gốc). Không nhắc
  notarize như bản 1.6.1.

## Việc 2 — Công cụ kiểm cập nhật cục bộ: `scripts/prepare-local-update-test.sh` (mới)
Chỉ tạo file trong thư mục output; **không** chép vào `/Applications`, không chạy server, không upload.
- `usage: prepare-local-update-test.sh SIGNED_APP RELEASE_NOTES NEW_OUTPUT_DIR SPARKLE_BIN [PORT]` (PORT mặc định `8765`);
  `ACCOUNT="${MKEY_SPARKLE_ACCOUNT:-io.github.akachick113.mkeyjis}"`; từ chối output đã tồn tại.
- `verify-release-signature.py SIGNED_APP` phải pass. Đọc `VERSION` / `BUILD` từ Info.plist; `BUILD` phải ≥ 2.
- `OUTPUT/feed/`: zip `SIGNED_APP` thành `mkey-jis-$VERSION.zip` (đúng lệnh `ditto` của `build-update-feed.sh`), chép
  notes thành `mkey-jis-$VERSION.md`, `generate_appcast --account "$ACCOUNT" --download-url-prefix
  "http://127.0.0.1:$PORT/" --release-notes-url-prefix "http://127.0.0.1:$PORT/" --maximum-deltas 0 "$OUTPUT/feed"`, rồi
  `sign_update --verify --account "$ACCOUNT" "$OUTPUT/feed/appcast.xml"`.
- `OUTPUT/old/mkey-jis.app` — "bản cũ" chỉ để thử: `ditto` `SIGNED_APP` vào thư mục tạm (`mktemp -d`, `trap` xoá), sửa
  Info.plist bằng `PlistBuddy`: `CFBundleVersion` = `BUILD - 1`, `CFBundleShortVersionString` = `$VERSION-old`,
  `SUFeedURL` = `http://127.0.0.1:$PORT/appcast.xml`, thêm `NSAppTransportSecurity` (dict) →
  `NSAllowsLocalNetworking` = true; rồi `scripts/sign-release.sh <bản tạm> "$OUTPUT/old"` (ký lại toàn bộ, cùng chứng chỉ).
- In hướng dẫn bước tiếp (server: `python3 -m http.server $PORT --bind 127.0.0.1 --directory "$OUTPUT/feed"`; chép
  `OUTPUT/old/mkey-jis.app` vào `/Applications`) và cảnh báo: bản `old` trỏ feed cục bộ, **không bao giờ phát hành**.

## Việc 3 — `scripts/check.sh`
Thêm bước (sau bước "Kiểm tra trùng phím tắt macOS", cùng kiểu):
`echo "==> Kiểm tra chữ ký bản phát hành"` → `python3 tests/release-signature-tests.py | tee
build/tests/release-signature-results.txt`; thêm file kết quả vào lệnh `cat` cuối. Không đổi bước khác. CI không cần
chứng chỉ (test chỉ dùng hàm thuần).

## Ca test bắt buộc (mỗi ca một hàm riêng trong `tests/release-signature-tests.py`, tên có số ca)
Nạp module bằng `importlib.util.spec_from_file_location` từ `scripts/verify-release-signature.py`. Framework tự viết như
các file test khác: mỗi ca một hàm `caseNN_…`, lỗi thì in ca + thoát ≠ 0, cuối in `PASS: 6 release signature tests`.
Fixture dựng từ hai mẫu `codesign -dv` thật ở Hiện trạng: `SIGNED` (team `8C4YAMZSGP`, runtime, Timestamp, universal) và
`ADHOC` (mẫu `Autoupdate` trước khi ký lại); helper `good()` trả dict đủ 6 component = `SIGNED`.

65. `case65_allComponentsSigned`: `signature_problems(good(), '8C4YAMZSGP') == []`.
66. `case66_adhocHelperRejected`: với **từng** helper trong 4 helper (`Downloader.xpc`, `Installer.xpc`, `Autoupdate`,
    `Updater.app`), thay bằng `ADHOC` → có lỗi, mọi lỗi đều nhắc đúng helper đó (không nhắc component khác). Đây là trạng
    thái thật của bản Release ở 4a.
67. `case67_wrongTeamRejected`: app có `TeamIdentifier=CF5PGH3KGK` → có lỗi nhắc app; `team` truyền vào khác (`'XXXXXXXXXX'`)
    với `good()` → mỗi component đều có lỗi.
68. `case68_missingComponentRejected`: xoá khoá `Installer.xpc` → có lỗi nhắc `Installer.xpc`; đặt `Autoupdate` = `None` →
    có lỗi nhắc `Autoupdate`.
69. `case69_runtimeAndTimestampRequired`: app có `flags=0x0(none)` → có lỗi; `Sparkle.framework` bỏ dòng `Timestamp=` → có
    lỗi nhắc framework.
70. `case70_universalAppRequired`: app có `Format=app bundle with Mach-O thin (arm64)` → có lỗi; helper có `Format=Mach-O
    thin (arm64)` → **không** lỗi (chỉ app bắt buộc universal).

Ca 1–64 giữ nguyên expectation.

## Không được làm
- Không đổi visibility repo, không tạo / push tag, không tạo GitHub Release, không upload asset (người dùng làm sau khi
  merge). Không xoá các tag `v1.0.0`…`v1.6.1` có sẵn trên origin.
- Không tạo / xuất / nhập khoá Sparkle (`generate_keys` chỉ `-p`); không commit khoá, chứng chỉ, `.p12`, file trong `build/`
  (feed, zip, app đã ký). Không dùng `--force` / sửa ACL Keychain.
- Không sửa `project.yml` (cấu hình ký giữ như 4a), `Sources/` ngoài 2 dòng version của `Info.plist`, `SU*` khác, `.github/`.
  Không sửa `AGENTS.md`, `CLAUDE.md`, `docs/PLAN.md`, `docs/PRODUCT_SPEC.md`, `docs/notes/`, `docs/releases/1.6.1.md`.
- Không xoá bỏ / bỏ qua `codesign --verify --deep --strict` hiện có; không tắt `SURequireSignedFeed`,
  `SUVerifyUpdateBeforeExtraction`; không thêm feed override vào code app (bản `old` chỉ sửa Info.plist của bản sao).
- Không chạy hai bộ gõ cùng lúc: thoát `MKey JIS Debug` trước khi mở bản Release; không chọn Input Method "MKey".
- Không sửa expectation ca 1–64. Không thêm / nâng dependency (chỉ Python thư viện chuẩn). Không push `main`.
- Ngoài phạm vi (ghi báo cáo nếu thấy cần): keycap Tab / Delete / Esc / Home / End / PgUp / PgDn / Forward Delete / Help.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `PASS: 14 update runtime policy checks`, `PASS: 50 engine tests`,
      `PASS: 8 hotkey key name tests`, `PASS: 6 system hotkey conflict tests`, `PASS: 6 release signature tests`. CI xanh.
- [ ] Đủ ca 65–70, mỗi ca một hàm.
- [ ] `scripts/notarize.sh` không còn; `git grep -n -E 'notarytool|stapler|MFinder|notarize\.sh|CF5PGH3KGK|Phase 4b' --
      scripts tests docs/UPDATES.md README.md project.yml` **không in gì** (dán kết quả).
- [ ] Kịch bản chạy thật — máy JIS này, input source ABC + Japanese – Romaji (không chọn Input Method "MKey"), mkey gốc
      không chạy, `MKey JIS Debug` đã thoát. `BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin`.
      Ghi kết quả từng mục:
  - (a) Build Release universal (lệnh ở Hiện trạng) từ commit cuối của nhánh. `scripts/verify-release-signature.py
    build/DerivedData/Build/Products/Release/mkey-jis.app` → **thất bại**, liệt kê đúng 4 helper (dán output).
  - (b) `scripts/sign-release.sh build/DerivedData/Build/Products/Release/mkey-jis.app build/release-1.7.0` → `PASS: release
    signatures …` + `Signed app ready`. Dán `codesign -dv --verbose=2` (dòng `Identifier`, `flags`, `Authority` đầu,
    `Timestamp`, `TeamIdentifier`) của 6 thành phần, `codesign -d -r-` của app (DR như Hiện trạng), `lipo -archs` của
    executable app và `Autoupdate`, `plutil -p` (bundle id, tên, `1.7.0` / `14`). App nguồn trong `build/DerivedData` vẫn
    còn helper ad-hoc (script không sửa nguồn). Chạy lại vào cùng output → bị từ chối.
  - (c) `scripts/build-update-feed.sh build/release-1.7.0/mkey-jis.app docs/releases/1.7.0.md build/update-1.7.0 "$BIN"` →
    `Verified release assets … (version 1.7.0, build 14)`; dán `grep -E 'url=|sparkle:releaseNotesLink|<link>|sparkle:version'
    build/update-1.7.0/appcast.xml`. Cùng lệnh với app thô `build/DerivedData/…/mkey-jis.app` (output mới) → bị từ chối ở
    bước kiểm chữ ký. `git status` sạch (notes trong repo không bị `generate_appcast` sửa).
    `python3 tests/run-update-smoke.py build/update-1.7.0/appcast.xml` → 4 dòng `PASS:`.
  - (d) `scripts/prepare-local-update-test.sh build/release-1.7.0/mkey-jis.app docs/releases/1.7.0.md build/local-update-1.7.0
    "$BIN"` → feed cục bộ + `old/mkey-jis.app`. `plutil -p` bản old: `1.7.0-old` / `13`, `SUFeedURL` `http://127.0.0.1:8765/…`,
    có `NSAllowsLocalNetworking`; `verify-release-signature.py` bản old pass; DR bản old **giống hệt** bản mới.
  - (e) **Cập nhật thật bản cũ → mới** (phần chính của phase):
    1. Chạy server ở nền (lệnh script in ra). `ditto build/local-update-1.7.0/old/mkey-jis.app /Applications/mkey-jis.app`.
    2. Mở `/Applications/mkey-jis.app`. **Người dùng** cấp quyền Trợ năng cho **MKey JIS** (mục mới, khác `MKey JIS
       Debug`). TextEdit, Telex `tieengs vieetj` → `tiếng việt`; JIS `ddaay` → `đây`. Ghi PID (`pgrep -x mkey-jis`).
    3. Menu bar → "Kiểm tra cập nhật…" → cửa sổ Sparkle báo có `1.7.0` (ghi nội dung ghi chú phát hành hiện ra) → "Cài đặt và
       mở lại" (Codex hoặc người dùng bấm). Log server phải có `GET /appcast.xml`, `GET /mkey-jis-1.7.0.zip`.
    4. Sau khi app tự mở lại: PID mới khác PID cũ; `plutil -p /Applications/mkey-jis.app/Contents/Info.plist` → `1.7.0` /
       `14`, `SUFeedURL` GitHub thật, không còn `NSAppTransportSecurity`; `verify-release-signature.py
       /Applications/mkey-jis.app` pass; `xattr -l /Applications/mkey-jis.app` không có `com.apple.quarantine`.
    5. **Không cấp lại quyền**: gõ ngay `tieengs vieetj` / `ddaay` trong TextEdit → đúng; Cài đặt hệ thống → Trợ năng chỉ có
       **một** mục `MKey JIS`, đang bật. かな → Japanese, `nihongo⏎` ra chữ Nhật, 英数 về ABC.
    6. "Kiểm tra cập nhật…" lần nữa → feed GitHub thật trả lỗi (repo private) — ghi nguyên văn thông báo; đây là dự kiến,
       không phải lỗi.
    Bước nào thất bại (Sparkle từ chối `http`, lỗi cài đặt, mất quyền Trợ năng…) → **dừng**, dán log
    (`log show --last 5m --predicate 'process CONTAINS "Autoupdate" OR process CONTAINS "Updater" OR process == "mkey-jis"'`),
    không tự đổi cách ký / cấu hình Sparkle để vượt qua.
  - (f) Lần mở đầu khi có quarantine (README bước 4): thoát MKey JIS; `ditto -x -k build/update-1.7.0/mkey-jis-1.7.0.zip
    <thư mục tạm trong build/>`; `xattr -w com.apple.quarantine "0081;$(printf %x $(date +%s));Safari;"` lên app giải nén;
    `open` app đó → ghi nguyên văn hộp thoại macOS. **Người dùng** vào Cài đặt hệ thống → Quyền riêng tư & Bảo mật → ghi
    nút hiện ra ("Vẫn mở"…), bấm, app mở được. Thoát app, xoá bản tạm. Nếu macOS 27 không cho "Vẫn mở" mà chỉ còn cách
    `xattr -dr` → ghi lại (README sẽ sửa ở phase sau).
  - (g) Dọn: dừng server; thoát MKey JIS; xoá `/Applications/mkey-jis.app` (bản ứng viên — bản chính thức cài sau khi phát
    hành); **giữ** mục Trợ năng `MKey JIS` (bản chính thức cùng DR dùng lại được). Giữ `build/release-1.7.0`,
    `build/update-1.7.0` (không commit) để Claude review; xoá `build/local-update-1.7.0`.
- [ ] PR đã mở vào `main` của `origin`.

## Khi xong
Commit theo từng bước (Conventional Commits tiếng Việt; Việc 0 = `fix:` / `chore:` cho script, `docs:` cho tài liệu;
Việc 1 `chore: …` version; Việc 2 + 3 `feat:` / `test:`). Push nhánh `phase-4b-release-pipeline`, **mở PR vào `main`** và
gửi link. Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả từng kịch bản (a)–(g), dán các output được yêu cầu; (e) ghi rõ từng bước 1–6 và ai bấm gì.
3. Kết quả lệnh `git grep` ở Done khi.
4. Chỗ nào khác prompt và lý do.
5. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao) — đặc biệt: Sparkle có dùng `Installer.xpc` /
   `Downloader.xpc` khi cập nhật không (app không sandbox), hộp thoại Keychain có hiện lần nào không, hộp thoại Gatekeeper ở
   (f) trên macOS 27.
