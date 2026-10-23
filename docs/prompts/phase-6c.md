# Phase 6c — Build, ký, kiểm cập nhật và Gatekeeper cho VKey 1.0.0 (trước phát hành)

> Codex · **GPT-6 Sol** · effort **Medium** (không viết mã; kịch bản chạy thật nhiều bước có người dùng tham gia — Luna dễ bỏ
> bước, WORKFLOW §8) · **không có nhánh, không PR, không commit** · **session Codex mới**

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 6**: "✅ 6a xong" + Còn tồn, "✅ 6b xong", "6c — kế hoạch chi tiết"),
`docs/UPDATES.md` (mục "Tạo bản phát hành"), `docs/releases/1.0.0.md`, `README.md` mục "Cài đặt & cấp quyền".

Repo giờ là `akachick113/vkey` (`origin`, **private**). Phase này làm bước 1–5 của UPDATES "Tạo bản phát hành" cho **VKey 1.0.0
(build 2)** và kiểm Gatekeeper bằng một lần tải thật qua Safari — **chưa** public, **chưa** tag, **chưa** Release (người dùng làm
sau khi Claude review). Không có mã nào phải sửa: nếu thấy cần sửa (script, README, ghi chú phát hành) → **dừng bước đó**, ghi
vào báo cáo, không tự sửa.

### Hiện trạng đã xem (Claude, `origin/main` @ `323ec6e`, máy JIS này, 2026-10-24)
- Build Release universal (lệnh UPDATES bước 2) trong worktree sạch: exit 0; `lipo -archs` executable = `x86_64 arm64`;
  `Info.plist`: `io.github.akachick113.vkey`, `VKey`, `1.0.0` / `2`, `LSMinimumSystemVersion` `14.0`, `SUFeedURL`
  `https://github.com/akachick113/vkey/releases/latest/download/appcast.xml`. App thô: `verify-release-signature.py` báo 4 helper
  Sparkle ad-hoc (đúng dự kiến).
- `scripts/sign-release.sh` lên bản sao → `PASS: release signatures (6 components, team 8C4YAMZSGP, universal)`, không hỏi
  Keychain. DR của app:
  `identifier "io.github.akachick113.vkey" and anchor apple generic and certificate leaf[subject.CN] = "Apple Development:
  akachick113@gmail.com (BCHZ2Y26CN)" and certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */`.
- `BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin` có `generate_keys`,
  `generate_appcast`, `sign_update`. `"$BIN/generate_keys" --account io.github.akachick113.vkey -p` =
  `fcqb3GZ6HvWXoXM+WpYSukjXRGF0mI0pYmJZTR7WTAE=` = `SUPublicEDKey`, không hỏi Keychain. Chỉ dùng **đúng** `BIN` này (công cụ
  Sparkle ở thư mục khác làm Keychain hỏi quyền và lệnh treo).
- Chứng chỉ ký duy nhất: `Apple Development: akachick113@gmail.com (BCHZ2Y26CN)`, hết hạn 2027-08-11.
- `/Applications` chưa có `VKey.app`. Đang chạy: **VKey Debug** từ `build/DerivedData/Build/Products/Debug/VKey.app` của
  checkout chính (bộ gõ hằng ngày của người dùng, đã có quyền Trợ năng).
- Danh sách Trợ năng của macOS hiện **tên file** app, nên bản Debug và bản Release đều hiện là **VKey** (Debug có thể hiện icon
  mkey cũ — cache icon, Còn tồn 6a C2). Mục của bản Release là mục trỏ `/Applications/VKey.app`.
- `tests/run-update-smoke.py` đọc app ở `build/DerivedData/Build/Products/Release` **của repo chứa script** → chạy từ worktree
  phát hành.
- Kinh nghiệm cũ: công cụ điều khiển máy của Codex gõ chuỗi thô, không qua event tap → **không** dùng nó làm bằng chứng gõ tiếng
  Việt. Gõ bằng `CGEventPost` với keyboard type 93 (JIS) như Phase 5d, hoặc nhờ người dùng gõ tay; ghi rõ cách nào. Cờ quarantine
  giả bằng `xattr -w` không làm hiện hộp thoại Gatekeeper (review 4b) → phải tải thật bằng trình duyệt.

## Biến dùng chung
```bash
BIN=/Users/duc/Developer/mkey/build/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin
git -C /Users/duc/Developer/mkey fetch origin
COMMIT=$(git -C /Users/duc/Developer/mkey rev-parse origin/main)   # ghi vào báo cáo: commit sẽ được tag v1.0.0
REL=/Users/duc/Developer/vkey-release-1.0.0                          # worktree phát hành (UPDATES bước 2)
```
`COMMIT` phải là commit trên `origin/main` chứa file prompt này; giữa `b766993` và `COMMIT` chỉ được có thay đổi trong `docs/`
(`git diff --stat b766993 $COMMIT -- . ':!docs'` không in gì — dán kết quả).

## Kịch bản (theo thứ tự; ghi kết quả từng mục)
Trước khi bắt đầu: input source **ABC** + **Japanese – Romaji** (không chọn Input Method "MKey"); không bộ gõ tiếng Việt nào
khác chạy. **Không chạy hai VKey cùng lúc**: từ (d) trở đi VKey Debug phải đã thoát.

- **(a) Chuẩn bị** — UPDATES bước 1 (chỉ phần kiểm, version đã có): `security find-identity -v -p codesigning`, ngày hết hạn
  chứng chỉ, `generate_keys … -p` so với `SUPublicEDKey`. Dán output.
- **(b) Build** — UPDATES bước 2 với `<commit>` = `$COMMIT`, `<version>` = `1.0.0` → worktree `$REL`. `git -C $REL status
  --short` rỗng, `rev-parse HEAD` = `$COMMIT`. Dán `lipo -archs` của `Contents/MacOS/VKey` và của
  `Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate`.
- **(c) Ký** — UPDATES bước 3 trong `$REL`:
  `scripts/sign-release.sh build/DerivedData/Build/Products/Release/VKey.app build/release-1.0.0`. Dán dòng `PASS: …`,
  `codesign -d -r- build/release-1.0.0/VKey.app` (phải trùng DR ở Hiện trạng), `plutil -p` (bundle id, tên, `1.0.0` / `2`,
  `SUFeedURL`, `SUPublicEDKey`).
- **(d) Feed thật** — UPDATES bước 5 (bản đầu, **không** có tham số thứ năm):
  `scripts/build-update-feed.sh build/release-1.0.0/VKey.app docs/releases/1.0.0.md build/update-1.0.0 "$BIN"` →
  `Verified release assets … (version 1.0.0, build 2)`. Dán
  `grep -E 'url=|sparkle:releaseNotesLink|<link>|sparkle:version|sparkle:shortVersionString' build/update-1.0.0/appcast.xml`
  (URL phải là `https://github.com/akachick113/vkey/releases/download/v1.0.0/VKey-1.0.0.{zip,md}`), `ls -l build/update-1.0.0`
  (đúng 3 file `appcast.xml`, `VKey-1.0.0.zip`, `VKey-1.0.0.md`), `shasum -a 256` 3 file đó. `git -C $REL status --short` rỗng.
  Sau đó `python3 tests/run-update-smoke.py build/update-1.0.0/appcast.xml` (trong `$REL`) → dán các dòng `PASS:`.
  **Từ đây không được sửa / tạo lại 3 file trong `build/update-1.0.0`** — đó là file sẽ upload.
- **(e) Cập nhật thật `old` → 1.0.0** — UPDATES bước 4:
  1. Thoát VKey Debug (`osascript -e 'quit app id "io.github.akachick113.vkey.debug"'`, kiểm `pgrep -fl VKey` không còn).
  2. `scripts/prepare-local-update-test.sh build/release-1.0.0/VKey.app docs/releases/1.0.0.md build/local-update-1.0.0 "$BIN"`.
     `plutil -p` bản old: `1.0.0-old` / `1`, `SUFeedURL` `http://127.0.0.1:8765/appcast.xml`, có `NSAllowsLocalNetworking`;
     `codesign -d -r-` bản old trùng DR bản mới.
  3. Chạy server ở nền (lệnh script in ra); `ditto build/local-update-1.0.0/old/VKey.app /Applications/VKey.app`;
     `open /Applications/VKey.app`. **Người dùng** bật quyền Trợ năng cho mục **VKey** của `/Applications/VKey.app`. Ghi icon hiện
     cạnh mục đó (VKey hay mkey cũ — Còn tồn 6a C2).
  4. TextEdit: Telex `tieengs vieetj` → `tiếng việt`; `ddaay` → `đây`. Ghi PID (`pgrep -f /Applications/VKey.app`).
  5. Menu thanh menu → "Kiểm tra cập nhật…" → Sparkle báo có `1.0.0` (ghi phần ghi chú phát hành hiện ra) → "Cài đặt và mở lại"
     (ghi ai bấm). Log server có `GET /appcast.xml` và `GET /VKey-1.0.0.zip`.
  6. Sau khi app tự mở lại: PID mới khác PID cũ; `plutil -p /Applications/VKey.app/Contents/Info.plist` → `1.0.0` / `2`,
     `SUFeedURL` GitHub thật, không có `NSAppTransportSecurity`; `scripts/verify-release-signature.py /Applications/VKey.app`
     pass.
  7. **Không cấp lại quyền**: gõ ngay `tieengs vieetj` / `ddaay` → đúng. かな → Japanese, `nihongo⏎` ra chữ Nhật, 英数 về ABC.
  8. "Kiểm tra cập nhật…" lần nữa → feed GitHub thật lỗi vì repo còn private — ghi nguyên văn thông báo (dự kiến, không phải lỗi).
  9. Dừng server. **Giữ** `/Applications/VKey.app` đang chạy (đây chính là bản 1.0.0 đã ký) để qua (f).
- **(f) Gatekeeper trước phát hành** — tải đúng file sẽ upload, bằng trình duyệt thật, làm đúng README bước 2–4:
  1. Thoát VKey (`osascript -e 'quit app id "io.github.akachick113.vkey"'`); chuyển `/Applications/VKey.app` vào Thùng rác
     (Finder hoặc `osascript -e 'tell application "Finder" to delete POSIX file "/Applications/VKey.app"'`, không `rm -rf`).
  2. `python3 -m http.server 8766 --bind 127.0.0.1 --directory $REL/build/update-1.0.0` ở nền.
  3. **Người dùng** mở Safari, tải `http://127.0.0.1:8766/VKey-1.0.0.zip` → `~/Downloads`. Dán
     `xattr -p com.apple.quarantine ~/Downloads/VKey-1.0.0.zip` (phải có, agent Safari) và `shasum -a 256` (trùng (d)). Nếu
     Safari tự giải nén ("Mở tệp an toàn sau khi tải về") → ghi lại, dùng `VKey.app` Safari đã giải nén cho bước 4 và dán
     `xattr -l` của nó thay cho zip.
  4. **Người dùng** nhấp đúp zip trong Finder để giải nén, kéo `VKey.app` vào **Applications**, nhấp đúp mở. Dán
     `xattr -l /Applications/VKey.app` trước khi mở. Ghi **nguyên văn** hộp thoại macOS và các nút.
  5. **Người dùng** vào Cài đặt hệ thống → Quyền riêng tư & Bảo mật → ghi nút hiện ra (có "Vẫn mở" không, ở mục nào), bấm, ghi
     hộp thoại xác nhận (có đòi mật khẩu / Touch ID không), app mở được không.
  6. App mở → quyền Trợ năng có giữ không (cùng DR) — gõ `tieengs vieetj` → `tiếng việt`. Nếu bị đòi cấp lại: ghi lại, người dùng
     cấp, gõ lại.
  7. So kết quả 3–6 với README bước 3 và `docs/releases/1.0.0.md` bước 3 (câu "Vẫn mở" / `xattr -dr`). **Lệch** → ghi cụ thể câu
     nào sai và macOS 27 thực sự hiện gì; không sửa file.
  8. Dừng server; xoá `~/Downloads/VKey-1.0.0.zip` và thư mục giải nén (Thùng rác). **Giữ** `/Applications/VKey.app` chạy, để
     người dùng dùng hằng ngày và Claude kiểm giao diện ở review.
- **(g) Dọn** — xoá `$REL/build/local-update-1.0.0` (chứa bản `old` trỏ feed cục bộ — **không bao giờ phát hành**). **Giữ**
  worktree `$REL` cùng `build/release-1.0.0` và `build/update-1.0.0` cho Claude review và người dùng upload. VKey Debug để
  thoát (không mở lại).

Bước nào thất bại (build, ký, hộp thoại Keychain, Sparkle từ chối, cài lỗi, mất quyền Trợ năng không mong đợi…) → **dừng**,
dán output / log (`log show --last 5m --predicate 'process CONTAINS "Autoupdate" OR process CONTAINS "Updater" OR process ==
"VKey"'`), không tự đổi cách ký, cấu hình Sparkle hay tài liệu để vượt qua. Hộp thoại Keychain hiện → dừng, nhờ người dùng.

## Không được làm
- Không đổi visibility repo, không tạo / push tag, không tạo GitHub Release, không upload. Không push gì lên `origin`.
- Không tạo nhánh, không commit, không sửa file nào trong repo (kể cả `docs/`, `README.md`, script). Không chạy formatter.
- Không tạo / xuất / nhập khoá Sparkle (`generate_keys` chỉ `-p`); không sửa ACL Keychain; không dùng công cụ Sparkle ngoài
  `BIN`.
- Không sửa / tạo lại / ký lại file trong `build/update-1.0.0` sau (d). Không phát hành / đưa ai bản `old`.
- Không chạy hai VKey cùng lúc; không chọn Input Method "MKey". Không `rm -rf` app trong `/Applications` (dùng Thùng rác).
- Không gõ bằng công cụ gõ chuỗi thô làm bằng chứng gõ tiếng Việt.

## Done khi
- [ ] (a)–(g) có kết quả, dán đủ output được yêu cầu; bước nào người dùng làm ghi rõ.
- [ ] `build/update-1.0.0` có đúng 3 file, feed trỏ `…/releases/download/v1.0.0/`, chữ ký hợp lệ, smoke pass; `shasum` ghi lại.
- [ ] Cập nhật cục bộ: PID đổi, `1.0.0` / `2`, gõ được không cấp lại quyền.
- [ ] Gatekeeper: nguyên văn hộp thoại + nút; kết luận README bước 3 / ghi chú phát hành **đúng** hay **phải sửa** (câu nào).
- [ ] `/Applications/VKey.app` 1.0.0 đang chạy, có quyền Trợ năng; VKey Debug đã thoát; `build/local-update-1.0.0` đã xoá.
- [ ] `git -C /Users/duc/Developer/mkey status --short` và `git -C $REL status --short` rỗng.

## Khi xong
Không có PR. Trả lời bằng tiếng Việt và **ghi toàn văn báo cáo vào `/Users/duc/Developer/mkey/build/phase-6c-report.md`**
(không commit), gồm:
1. Tóm tắt; `COMMIT`; kết quả `git diff --stat b766993 $COMMIT -- . ':!docs'`.
2. Kết quả từng mục (a)–(g) với output được yêu cầu; (e) và (f) ghi từng bước, ai bấm gì, cách gõ (CGEventPost / người dùng).
3. `shasum -a 256` 3 file trong `build/update-1.0.0`.
4. Kết luận Gatekeeper và đề xuất câu chữ nếu README / ghi chú phát hành phải sửa.
5. Chỗ khác prompt và lý do; chỗ chưa chắc / chưa kiểm được (và vì sao) — đặc biệt: hộp thoại Keychain có hiện lần nào không;
   icon mục Trợ năng.
