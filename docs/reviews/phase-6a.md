# Review Phase 6a — Dọn còn tồn 5d + chuẩn bị VKey 1.0.0

PR #10 (`phase-6a-release-prep`) · Codex Luna · High · prompt [`prompts/phase-6a.md`](../prompts/phase-6a.md)

## Review lần 1 — `608e45c`

**Kết luận: Approved.** Không có Phải sửa / Nên sửa.

Kiểm tra trên worktree sạch (`git worktree add ../mkey-review 608e45c`, `xcodegen generate`, DerivedData mới):
`scripts/check.sh` ✅ — `PASS: 14 update runtime policy checks` · `PASS: 53 engine tests` · `PASS: 8 hotkey key name tests` ·
`PASS: 6 system hotkey conflict tests` · `PASS: 6 release signature tests` · `PASS: 5 keyboard mode tests`. Dòng
`error: the following command failed with exit code 0 but produced no further output` trong log là thông báo của xcodebuild
sau cảnh báo deprecated ở `ClipboardPicker.swift` (file không đổi), có từ trước, script vẫn exit 0.
- 2 commit đúng tên prompt (`fix: dọn còn tồn giao diện 5d`, `chore: chuẩn bị phát hành VKey 1.0.0`), chỉ 7 file ✅.
- Bảng `--numstat` có / không `-w` Claude tự chạy lại: **khớp từng dòng** bảng mong đợi ✅. Đọc diff: C1–C4 đúng nguyên văn
  prompt, không đổi dòng nào khác ✅.
- `docs/releases/1.0.0.md`: `diff` với đoạn giữa hai dòng `---8<---` của prompt → rỗng ✅. `PlistBuddy` → `1.0.0` / `2` ✅.
  README thêm đúng 1 gạch đầu dòng ở đúng chỗ ✅.
- CI: theo báo cáo Codex (`build/phase-6a-report.md`) run #65 job `check` xanh — Claude không xem được (repo private, không có
  `gh`).
- `Không được làm`: không đụng `project.yml`, `.github/`, `Engine/`, `Platform/`, `VKTheme`, `VKComponents`, `docs/` ngoài
  `releases/` ✅.

### Chạy thật (Claude, bản Debug ở checkout chính build từ `608e45c`)
Người dùng cho thoát bản Debug cũ (đang chạy từ 23/10) và cấp lại quyền Trợ năng cho bản build mới. Chỉ đọc Accessibility +
AXPress mở Cài đặt / chuyển trang, không gửi phím.
- C1 — submenu `Bàn phím` (`AXExtrasMenuBar`): đúng 3 mục `Tự động` / `JIS (Nhật)` / `Tiếng Anh (US)`, **hết 2 dải phân cách
  rỗng**; cấu trúc giống `Kiểu gõ` / `Bảng mã` ✅.
- C2 — trang Hệ thống, thẻ `CẬP NHẬT`: dòng `Cập nhật tự động được tắt trong bản phát triển.` bắt đầu ở x = 529, cùng lề trái
  với các hàng khác trong thẻ (trước đây căn giữa) ✅. Dòng `Kiểm tra lần cuối` không hiện ở bản Debug (chưa từng kiểm) — cùng
  modifier, kiểm bằng đọc mã.
- C3 — trang Chuyển mã: popup `Từ bảng mã` x 878…1093 và `Chuyển đổi` x 922…1093 → **cùng mép phải 1093** ✅ (`Sang bảng mã`
  có nút `Đảo chiều` bên phải, như cũ).
- C4 — trang Gõ tắt: `AXTextField Description=Từ tắt` và `AXTextField Description=Nội dung thay thế` ✅.
- Sau khi cấp quyền, menu đổi từ `Cấp quyền Trợ năng…` sang menu đầy đủ mà không cần mở lại app — khớp câu "App tự nhận quyền,
  không cần mở lại" trong ghi chú phát hành ✅.
- Người dùng thấy icon `mkey` cũ cạnh mục VKey trong danh sách Trợ năng: icon trong bản build (`AppIcon.icns`) là icon VKey mới,
  trùng `AppIcon.appiconset` → đó là cache icon của macOS cho đường dẫn này, không phải lỗi mã. Ghi để kiểm lại với bản Release ở
  `/Applications` (6c).

### Ghi cho 6c (không chặn 6a)
- Bản Debug chỉ có `arm64` (bình thường với Debug); ghi chú phát hành ghi "Apple Silicon và Intel" → 6c phải kiểm
  `lipo -archs` của bản Release = `x86_64 arm64` trước khi upload.
- Icon trong danh sách Trợ năng / Finder với bản cài ở `/Applications`.

Người dùng: **squash merge** PR #10 (kiểm commit squash có cây trùng `608e45c`). Sau đó Claude chốt PLAN và làm 6b.
