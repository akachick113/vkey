# Review Phase 7b — Phát hành VKey 1.0.1

PR #3 (`phase-7b-release-1.0.1`) · Codex Luna · High · prompt [`prompts/phase-7b.md`](../prompts/phase-7b.md)

## Review lần 1 — Phần A @ `2a97b95`

**Kết luận: Approved.** Không có Phải sửa / Nên sửa. Người dùng squash merge PR #3 (tiêu đề giữ
`chore: chuẩn bị phát hành VKey 1.0.1`), rồi nhắn Codex làm **Phần B** với `<SHA Review lần 1 ghi>` = **`2a97b95`**.

Kiểm tra trên worktree sạch @ `2a97b95` (cha `9252137` = `origin/main`):
- `scripts/check.sh` ✅ — `14 / 53 / 8 / 6 / 6 / 5`. CI run #19 xanh (báo cáo Codex).
- Một commit đúng tên ✅. Bảng `numstat` có / không `-w` khớp **đúng** prompt
  (`2 2` `Info.plist`, `16 0` `docs/releases/1.0.1.md`) ✅; diff `Info.plist` chỉ 2 dòng `<string>` (không bị sắp xếp lại khoá) ✅.
- `PlistBuddy` → `1.0.1` / `3` ✅; `docs/releases/1.0.1.md` `diff` với bản trong prompt → rỗng ✅.
