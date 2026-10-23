# Review Phase 4b — PR #6, nhánh `phase-4b-release-pipeline` (vòng 1 `6c4a986`, vòng 2 `ef79062`)

## Review lần 1 — `6c4a986`

**Kết luận: Cần sửa — 1 mục Phải sửa (chỉ tài liệu), 1 mục Nên sửa.** Code, test và kịch bản chạy thật đạt; cập nhật
thật bản cũ → mới qua feed cục bộ thành công, quyền Trợ năng giữ nguyên.

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review 6c4a986`, DerivedData mới):
`scripts/check.sh` ✅ (build Debug ✅ · `PASS: 14 update runtime policy checks` · `PASS: 50 engine tests` ·
`PASS: 8 hotkey key name tests` · `PASS: 6 system hotkey conflict tests` · `PASS: 6 release signature tests`) · CI #34 xanh
(theo báo cáo Codex; Claude không xem được CI repo private) · chỉ đụng 11 file trong phạm vi: không sửa `project.yml`,
`Sources/` ngoài 2 dòng version, `.github/`, `AGENTS.md`, `docs/PLAN.md`, `docs/releases/1.6.1.md` ✅ · không thêm
dependency, không commit `build/` / khoá ✅ · không tag, không Release, repo vẫn private ✅ · 4 commit Conventional Commits
tiếng Việt ✅ · `git grep -n -E 'notarytool|stapler|MFinder|notarize\.sh|CF5PGH3KGK|Phase 4b' -- scripts tests
docs/UPDATES.md README.md project.yml` không in gì ✅ (`notarize.sh` → `sign-release.sh`, git nhận là rename).

Báo cáo "Khi xong" của Codex ở `build/phase-4b-evidence/REPORT.md` (kèm output từng bước) — đầy đủ, trung thực, ghi rõ
chỗ chưa kiểm được.

Đối chiếu prompt từng việc:
- Việc 0 C1a ✅ — `verify-release-signature.py`: `COMPONENTS` đúng 6 mục, đúng thứ tự; `signature_problems` thuần, đủ 6 luật
  (thiếu, ad-hoc theo `Signature=` **hoặc** cờ, team, runtime, Timestamp, app universal); CLI đọc stderr của `codesign
  -dv`, thêm `codesign --verify --deep --strict`, in đúng dòng `PASS: …`.
- C1b ✅ — `sign-release.sh`: copy sang `$OUTPUT/mkey-jis.app`, ký 6 thành phần đúng thứ tự / cờ, giữ chú thích, bỏ hết
  notarize / staple / `spctl`, gọi verifier cuối.
- C1c ✅ — `build-update-feed.sh` gọi verifier ngay sau `codesign --verify`.
- C1d ✅ — `UPDATES.md` viết lại đủ 7 bước, gạch hết hạn chứng chỉ + `MKEY_SIGNING_IDENTITY`, đoạn bundle id riêng, mục Kiểm
  thử; `README.md:98-99` đã bỏ 2 câu.
- Việc 1 ✅ — `1.7.0` / `14`; `docs/releases/1.7.0.md` đúng cấu trúc, không nhắc notarize như bản 1.6.1.
- Việc 2 ✅ — `prepare-local-update-test.sh` đúng đặc tả (kiểm chữ ký, `BUILD ≥ 2`, feed `http://127.0.0.1:$PORT/`,
  `sign_update --verify`, bản `old` sửa 4 khoá rồi ký lại qua `sign-release.sh`, in hướng dẫn + cảnh báo).
- Việc 3 ✅ — bước test mới trong `check.sh`, có trong `cat` cuối.
- Ca 65–70 ✅ — mỗi ca một hàm có số ca. Test bắt lỗi tốt — tắt tạm từng luật trong `signature_problems`: bỏ luật ad-hoc →
  đỏ ca 66; bỏ runtime → đỏ 69; bỏ Timestamp → đỏ 69; bỏ universal → đỏ 70; áp universal cho mọi component → đỏ 70; bỏ
  nhánh thiếu component → đỏ (exception). Ca 67 ghép `'CF5' + 'PGH3KGK'` để lệnh `git grep` của Done khi không bắt nhầm —
  hợp lý.

## Chạy thật

**Claude tự chạy lại (a)–(d)** trên worktree sạch, công cụ Sparkle ở checkout chính (không hộp thoại Keychain):
- (a) ✅ Build Release universal thành công; verifier trên app thô → exit 1, liệt kê đúng 4 helper (ad-hoc / team / Timestamp).
- (b) ✅ `sign-release.sh` → `PASS: release signatures (6 components, team 8C4YAMZSGP, universal)`; chạy lại cùng output →
  `Use a new output directory`, exit 1; DR app như Hiện trạng; `lipo` → `x86_64 arm64`; `1.7.0` / `14`; app nguồn vẫn ad-hoc.
- (c) ✅ `build-update-feed.sh` → `Verified release assets: build/update-1.7.0 (version 1.7.0, build 14)`; enclosure
  `…/akachick113/mkey-jis/releases/download/v1.7.0/mkey-jis-1.7.0.zip`, notes `…/mkey-jis-1.7.0.md`, `<link>` repo mới,
  `sparkle:version` 14. Cùng lệnh với app thô → dừng ở bước kiểm chữ ký, không tạo output. `docs/releases/1.7.0.md` không
  bị `generate_appcast` sửa. Smoke test không chạy lại (bật cửa sổ Sparkle trên máy người dùng; Codex đã chạy 4/4 PASS).
- (d) ✅ `prepare-local-update-test.sh` → feed cục bộ ký khoá thật; bản old `1.7.0-old` / `13`, `SUFeedURL`
  `http://127.0.0.1:8765/appcast.xml`, `NSAllowsLocalNetworking`; DR bản old **giống hệt** bản mới. Đã xoá thư mục thử.

**(e)–(g): dựa trên bằng chứng của Codex** (Claude không chạy lại vì phải điều khiển UI / gõ phím trên máy người dùng):
- (e) ✅ — chạy 2 lượt, lượt 2 có kiểm soát: bản old (PID 91546) gõ đúng → Sparkle báo `MKey JIS 1.7.0 hiện đã có—bạn đang
  dùng 1.7.0-old`, ghi chú phát hành hiện đúng → "Cài đặt và khởi động lại" → server log `GET /appcast.xml`, `GET
  /mkey-jis-1.7.0.md`, `GET /mkey-jis-1.7.0.zip` → app tự mở lại PID 91902, `1.7.0` / `14`, feed GitHub thật, không còn ATS,
  verifier PASS, không `com.apple.quarantine`; gõ `tiếng việt` / `đây` ngay, không cấp lại quyền; かな `nihongo⏎` → `日本語`,
  英数 → ABC; kiểm cập nhật lần nữa → `Lỗi cập nhật!` (feed private 404, dự kiến). Log hệ thống chỉ có `Autoupdate`
  thực thi (xác thực chữ ký) — `Installer.xpc` / `Downloader.xpc` không được dùng vì app không sandbox, vẫn ký team cho đủ.
- (f) ⚠️ Chưa kiểm được: app có quarantine (`0081;…;Safari;`) mở thẳng qua App Translocation, **không** có hộp thoại
  Gatekeeper dù `spctl` → rejected. Có thể do chuỗi quarantine giả lập trong prompt (cờ `0081`, không phải tải thật) hoặc
  trạng thái máy phát triển — **lỗi đo do prompt**, không tính cho PR. Chuyển sang 4c: tải zip thật bằng trình duyệt từ
  Release, mở bằng Finder.
- (g) ✅ — dọn đúng; giữ mục Trợ năng.

Phát hiện khi đọc bằng chứng (e) bước 5: trong Cài đặt hệ thống → Trợ năng, mục của bản Release hiện là **`mkey-jis`**
(tên file app), không phải "MKey JIS" — cùng kiểu mkey gốc (`mkey.app`, `CFBundleName` `MKey`) hiện là `mkey`. Hệ quả
→ Phải sửa 1.

## Phải sửa
1. **Hướng dẫn cấp quyền Trợ năng gọi sai tên mục** (lỗi do prompt 4a / 4b — cả hai đặc tả "cấp quyền cho **MKey JIS**").
   Người cài sẽ tìm "MKey JIS" trong danh sách Trợ năng nhưng mục thật là `mkey-jis`. Ghi chú phát hành 1.7.0 được ký vào
   feed và hiện trong cửa sổ Sparkle → sửa trước khi phát hành:
   - `README.md` bước 5 "Cài đặt & cấp quyền": `bật **MKey JIS**` → `bật **mkey-jis** (tên file của MKey JIS)`; giữ phần
     còn lại.
   - `docs/releases/1.7.0.md` bước 5: `cho **MKey JIS**` → cùng cách viết như README.
   - `docs/UPDATES.md` bước 4: `cấp Trợ năng cho **MKey JIS**` → `cấp Trợ năng cho mục **mkey-jis**`.
   Không đổi tên app / file / bundle. Kiểm: `git grep -n 'Trợ năng' -- README.md docs/releases/1.7.0.md docs/UPDATES.md`
   — mọi câu hướng dẫn bật quyền đều nhắc `mkey-jis`. Không cần build / chạy lại kịch bản.

## Nên sửa
1. **`docs/UPDATES.md` bước 2 build bằng `git switch main` + `git pull` ở checkout chính** — dự án này Codex chạy local
   cùng thư mục, đổi nhánh ở checkout chính sẽ phá việc đang làm. Đổi khối lệnh sang worktree riêng:
   `git fetch origin && git worktree add --detach ../mkey-release-<version> <commit>`, `cd` vào đó, `xcodegen generate` +
   lệnh Release; các bước 3–5 chạy trong worktree đó, `BIN` vẫn trỏ checkout chính (đã ghi ở bước 1/5); cuối quy trình
   `git worktree remove ../mkey-release-<version>`. Tiện thể đổi tiêu đề file `# Cập nhật MKey bằng Sparkle` →
   `# Cập nhật MKey JIS bằng Sparkle`.

## Done khi (vòng 2)
- [ ] Phải sửa 1 xong (3 file).
- [ ] (Nên) Nên sửa 1.
- [ ] `scripts/check.sh` vẫn `14 / 50 / 8 / 6 / 6`; `git grep` ở Done khi của prompt vẫn không in gì. Commit `docs: …`, push
      cùng nhánh, chuyển PR khỏi Draft. Không cần chạy lại (a)–(g); không cần dựng lại `build/update-1.7.0` (bản phát hành
      thật dựng lại ở 4c từ commit squash).

Model: giữ **Sol · Medium** (vòng 1 đúng phạm vi; Phải sửa do prompt).

## Còn tồn (đề xuất — người dùng chốt khi merge)
- Cho 4c: kiểm đường Gatekeeper thật — tải `mkey-jis-1.7.0.zip` từ Release bằng trình duyệt, giải nén bằng Finder, mở →
  ghi hộp thoại / nút "Vẫn mở" trên macOS 27; README bước 4 sửa theo kết quả.
- Cho 4c: bản phát hành thật build lại từ commit squash của 4b theo `UPDATES.md` (không dùng `build/release-1.7.0` của Codex
  — build từ nhánh, trước squash).
- Bản Debug cũng là `mkey-jis.app` nên mục Trợ năng của Debug và Release đều hiện `mkey-jis` (khác bundle id). Khi dùng cả
  hai, phân biệt bằng thứ tự / gỡ mục cũ — ghi nhận, chưa cần sửa.

## Review lần 2 — `ef79062`

**Kết luận: Approved.** Phải sửa 1 xong, Nên sửa 1 xong.

Một commit mới `ef79062 docs: sửa tên mục Trợ năng và build phát hành trong worktree`, chỉ đụng `README.md`,
`docs/UPDATES.md`, `docs/releases/1.7.0.md`. Worktree sạch `ef79062`: `scripts/check.sh` ✅ `14 / 50 / 8 / 6 / 6`;
`git grep` ở Done khi của prompt không in gì ✅.

- Phải sửa 1 ✅ — README bước 5 `bật **mkey-jis** (tên file của MKey JIS)`; ghi chú 1.7.0 bước 5 cùng cách viết;
  `UPDATES.md` bước 4 `cấp Trợ năng cho mục **mkey-jis**`. `git grep -n 'Trợ năng'` trên 3 file: mọi câu hướng dẫn bật
  quyền đều nhắc `mkey-jis`; các câu còn lại (gỡ mục `mkey` cũ, quyền giữ nguyên khi cùng chứng chỉ) đúng.
- Nên sửa 1 ✅ — bước 2 build trong `git worktree add --detach ../mkey-release-<version> <commit>`, ghi rõ bước 3–5 chạy
  trong worktree đó và `BIN` vẫn trỏ checkout chính (đường dẫn tuyệt đối ở bước 1); thêm khối dọn `git worktree remove`
  sau bước 7 (nhắc lưu gói cần giữ ra ngoài trước). Tiêu đề đổi thành `# Cập nhật MKey JIS bằng Sparkle`.

Lưu ý cho 4c: `build/update-1.7.0` Codex dựng ở vòng 1 có ghi chú phát hành **cũ** (tên mục Trợ năng sai) và build từ
nhánh — không dùng để phát hành; dựng lại từ commit squash theo `UPDATES.md` (đã ghi ở Còn tồn).

Sau khi merge, kiểm commit squash có nội dung giống `ef79062`.
