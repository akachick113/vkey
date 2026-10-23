# Review Phase 0 — PR #1, nhánh `phase-0-check-ci` (commit `1e00aac`)

Kiểm tra trên worktree sạch (`git worktree add ../mkey-review 1e00aac`, DerivedData mới): `scripts/check.sh` ✅
(build Debug ✅ · `PASS: 14 update runtime policy checks` · `PASS: 16 engine tests`, 27 giây) · không thêm / nâng
dependency ✅ · không đụng `Sources/`, `project.yml`, `docs/prompts/` ✅ · `git diff -w --stat` = `git diff --stat`
(6 file, +385, không đổi khoảng trắng ngoài phạm vi) ✅ · không commit `mkey.xcodeproj` / `build/` ✅ · 3 commit
Conventional Commits tiếng Việt (`test:`, `build:`, `ci:`) ✅ · baseline: không có test đỏ mới ✅.

Làm tốt: harness mô phỏng đúng event tap (thứ tự `charData` ngược, restore thêm phím vừa gõ, bỏ qua engine khi
`vLanguage = 0`), cấu hình mặc định khớp `AppState.registerDefaultSettings` và có chú thích nguồn. Gặp mã hành động lạ
hoặc backspace vượt độ dài thì harness ném lỗi, nên không xanh nhầm. 16 ca, mỗi ca một hàm `caseNN_…`, khớp đúng bảng đặc tả.

Chạy thật (máy JIS, Xcode 27.1):
- (a) `PATH=/usr/bin:/bin bash scripts/check.sh` → `Lỗi: thiếu xcodegen. Cài bằng: brew install xcodegen`, mã thoát 1 ✅
- (b) Sửa tạm expectation ca 6 thành `to` (bản sao ngoài worktree) → `FAIL: case06_leftBracketAfterConsonant: actual:
  [tơ]; expected: [to]`, `FAIL: 1 engine tests; 15 passed`, mã thoát 1 ✅
- (c) Gõ thử bản Debug: **Claude chưa thử**. Lý do: phải cấp quyền Trợ năng cho bản build mới, mà đó là thao tác của
  người dùng. PR không đổi dòng nào trong `Sources/` nên app giống hệt baseline; kết quả (c) lấy theo báo cáo của Codex.
- CI: **Claude chưa xem được**. Repo private, trình duyệt của Claude chưa đăng nhập GitHub. Người dùng xác nhận run của
  PR #1 xanh trước khi merge.

## Phải sửa

Không có.

## Nên sửa (không chặn merge)

1. **Cảnh báo của engine lặp lại mỗi lần chạy check.** `-Wall` làm `Sources/Engine/Vietnamese.cpp:811` báo
   `-Wmissing-braces`. Lỗi này thuộc engine gốc, không sửa được trong repo này, nên chỉ gây nhiễu log. Chính prompt yêu
   cầu `-Wall`, nên đây là lỗi của prompt. Có thể thêm `-Wno-missing-braces` vào lệnh biên dịch test trong
   `scripts/check.sh` khi có dịp (Phase 1), không cần làm lại PR này.

## Done khi
- [x] `scripts/check.sh` xanh trên worktree sạch.
- [x] Đủ 16 ca ở Việc 4, mỗi ca một test riêng.
- [x] Kịch bản (a), (b).
- [ ] CI của PR #1 xanh (người dùng xác nhận).
- [ ] Kịch bản (c) có trong báo cáo PR của Codex.

**Kết luận: Approved**, merge (squash) khi hai mục cuối đạt.
