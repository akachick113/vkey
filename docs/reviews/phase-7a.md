# Review Phase 7a — Ẩn nút "Lịch sử phiên bản" của Sparkle

PR #2 (`phase-7a-hide-version-history`) · Codex Luna · High · prompt [`prompts/phase-7a.md`](../prompts/phase-7a.md)

## Review lần 1 — `7d9d26b`

**Kết luận: Approved.** Không có Phải sửa / Nên sửa.

Kiểm tra trên worktree sạch (`git worktree add --detach ../vkey-review 7d9d26b`, DerivedData mới):
`scripts/check.sh` ✅ — `14 / 53 / 8 / 6 / 6 / 5` (không đổi).
- 2 commit đúng tên prompt (`64b8cb2 fix: …`, `7d9d26b test: ca 79 …`), cha = `6479bca` (`origin/main`) ✅.
- Các dòng `+` / `-` của diff **trùng hệt** bản Claude đã áp thử khi viết prompt; bảng `numstat` có / không `-w`
  (`7 2` `UpdateChecker.swift`, `19 1` `UpdateControllerSmoke.swift`) khớp ✅. Không đụng file nào khác ✅.
- Release build + `tests/run-update-smoke.py` với `appcast.xml` thật của 1.0.0 (tải từ GitHub): `upToDate`, `available`,
  `failed`, `failed` — 4 PASS ✅. Ca 79 ở chế độ âm tính (bỏ Việc 1) → `FAIL: … version history button shown`: Codex chạy (báo
  cáo) và Claude đã chạy khi viết prompt ✅. CI run #15 xanh (báo cáo Codex).
- Lệch prompt nhỏ, chấp nhận: Codex hoàn tác tạm bằng bản `UpdateChecker.swift` của `origin/main` thay vì `git stash` (đã commit
  trước khi chạy smoke) và khôi phục lại; nhánh sạch.
- Codex đã gỡ đăng ký bản build Release / Debug khỏi LaunchServices; không mở VKey nào ✅.

### Còn tồn Phase 6 — C2 (kiểm giao diện 6a C3)
- **Chào mừng nền sáng** ✅ — bản Debug @ `7d9d26b` chưa có quyền Trợ năng (không tạo event tap, không đụng
  `/Applications/VKey.app` đang chạy), ép nền sáng riêng cho domain `.debug` bằng `NSRequiresAquaSystemAppearance` (đã xoá
  sau khi chụp). Nền kem, chữ `text`, thẻ `card` có viền, nút `accent` chữ `onAccent`, chấm trạng thái `accent` — đúng DESIGN.
  Ảnh: [`assets/phase-7a-welcome-light.png`](./assets/phase-7a-welcome-light.png). Nền tối cũng xem lại: đạt.
- **Bảng clipboard (HTML / ảnh / hover)** và **Tab + VoiceOver** — cần bản có quyền Trợ năng và thao tác phím thật, không chạy
  được song song bộ gõ đang dùng → nhờ người dùng thử tay trên `/Applications/VKey.app` (giao diện 1.0.0 = 7a), không chặn
  phát hành 1.0.1:
  1. Bật Lịch sử clipboard; chép một đoạn từ Safari (HTML) và một ảnh (⌃⇧⌘4); mở bảng lịch sử → hai mục có icon loại mục rõ,
     rê chuột đổi nền hàng, hàng chọn nền đỏ son chữ trắng.
  2. Mở Cài đặt VKey, bấm Tab nhiều lần → vòng focus đi qua sidebar và các công tắc; bật VoiceOver (⌘F5) → đọc đúng tên trang
     và tên công tắc tiếng Việt; tắt VoiceOver (⌘F5).

Người dùng: **squash merge** PR #2 (kiểm commit squash có cây trùng `7d9d26b`). Sau đó Claude viết prompt 7b (phát hành
1.0.1).
