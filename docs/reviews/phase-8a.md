# Review Phase 8a — Tên tác giả ở Giới thiệu, rút gọn ghi công, công tắc nhỏ hơn

PR #4 (`phase-8a-gioi-thieu-cong-tac`) · Codex Luna · Medium · prompt [`prompts/phase-8a.md`](../prompts/phase-8a.md)

## Review lần 1 — `3517201`

**Kết luận: Approved.** Không có Phải sửa / Nên sửa.

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review 3517201`, `xcodegen generate`, DerivedData mới):
`scripts/check.sh` ✅ — `14 / 53 / 8 / 6 / 6 / 5` (không đổi); chỉ còn cảnh báo deprecated `activateIgnoringOtherApps` có sẵn.
CI (`check`) của `3517201` xanh ✅. PR mở vào `main`, không Draft ✅.
- 2 commit đúng tên prompt (`85156d1 feat: ghi tên tác giả …`, `3517201 feat: thu nhỏ công tắc …`), cha = `d044adb` ✅.
- `numstat` khớp (`1 2` AboutPage, `2 1` TypingPage, `1 1` VKComponents, `1 1` Info.plist); các dòng `+` / `-` **trùng hệt**
  bản Claude áp thử khi viết prompt ✅. Không đụng `NOTICE.md`, README, `Sources/Engine/`, version ✅.
- `grep "Dựa trên"` rỗng ✅. `grep "controlSize(.small)"` ra **5** dòng, không phải 3 — **lỗi của prompt**: 2 dòng có sẵn từ trước
  (`SystemPage.swift:47` `ProgressView`, `AboutPage.swift:49` nút Kiểm tra cập nhật). 3 dòng mới đúng 3 công tắc ✅.
- `Info.plist` của bản Debug vừa build: `NSHumanReadableCopyright` = `VKey © 2026 Trung Đức (akachick113). GPL v3.` ✅.

### Giao diện
Bản Debug chưa có quyền Trợ năng chỉ mở cửa sổ Chào mừng (không vào được Cài đặt), mà cấp quyền thì sẽ chạy hai event tap cùng
`/Applications/VKey.app`. Claude dựng ảnh từ **chính mã view** (`VKTheme.swift`, `VKComponents.swift`, `AboutPage.swift` của
`origin/main` = trước, của `3517201` = sau; `UpdateChecker` thay bằng stub; `NSHostingView` nền tối / sáng). Dòng "Phiên bản 1.0
(1)" trong ảnh là do harness không có `Info.plist`, không phải lỗi.
- Công tắc 54 × 24 → 44 × 20 pt, màu `accent` / tắt giữ nguyên, hàng thấp hơn 4 pt, chữ không đổi ✅ —
  [tối](assets/phase-8a-switch-dark.png), [sáng](assets/phase-8a-switch-light.png) (trái = trước, phải = sau).
- Giới thiệu: `Phát triển bởi **Trung Đức** (akachick113) · © 2026`, câu ghi công OpenKey / mkey không còn, 3 link giữ nguyên ✅ —
  [tối](assets/phase-8a-about-dark.png), [sáng](assets/phase-8a-about-light.png).

Chưa kiểm được trong app chạy thật: trang Hệ thống (danh sách app Trợ năng, `AXSupportAppRow`) và cả cửa sổ cài đặt thật → kiểm ở
bước chấp nhận 8b (cập nhật thật 1.0.1 → 1.0.2 trên `/Applications/VKey.app`).

### Sự cố quy trình (lỗi của Claude, đã sửa)
Khi Claude commit `docs: chốt phát hành 1.0.2 sau phase 8a`, checkout chính đã bị Codex chuyển sang nhánh `phase-8a…` → commit
`3e5467a` nằm nhầm trên nhánh phase (chưa push, PR #4 không dính) và `push origin main` không đẩy gì. Đã cherry-pick sang `main`
(`57fd89b`) qua worktree riêng và `git reset --keep 3517201` nhánh phase → nhánh local = `origin/phase-8a…`. Từ nay Claude chỉ
commit docs qua worktree `main` riêng.

Merge: squash, tiêu đề `feat: tinh chỉnh Giới thiệu và công tắc` (đã có tiền tố). Sau merge → Claude viết prompt 8b (1.0.2 / 4).
