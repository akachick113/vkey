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

## Kiểm Phần B — tài sản 1.0.1 (Claude, 2026-10-24)
`MERGE` = `f447469` (squash PR #3, cây = `2a97b95`). Worktree `/Users/duc/Developer/vkey-release-1.0.1` @ `f447469`, sạch.
`build/update-1.0.1`: đúng 3 file, SHA-256 khớp báo cáo (`appcast.xml` `66d4bdd4…`, `VKey-1.0.1.zip` `a5c8aff4…`,
`VKey-1.0.1.md` `5e079fdb…`); `sign_update --verify` feed pass; `verify-update-feed.py` → `PASS: archive, feed, release notes
signatures and tamper rejection`; ghi chú = `docs/releases/1.0.1.md` @ `f447469`. Feed **2 mục**: `1.0.1` build 3 →
`…/download/v1.0.1/VKey-1.0.1.zip`; mục `1.0.0` build 2 **trùng từng byte** mục trong feed đang phát hành. Giải nén zip → app
`1.0.1` / `3`, universal, 6 chữ ký pass, CDHash `093b3a34e94ba7f5ad82878e90b9c82908bb5cbf`, DR như 1.0.0. Smoke 4/4 (báo cáo).
Không chạy feed cục bộ / bản `old` (đúng PLAN 7b bước 4). **Sẵn sàng phát hành.**
