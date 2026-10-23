# Review Phase 8b — Phát hành VKey 1.0.2

PR #5 (`phase-8b-release-1.0.2`) · Codex Luna · High · prompt [`prompts/phase-8b.md`](../prompts/phase-8b.md)

## Review lần 1 — `2d9cbf6` (Phần A)

**Kết luận: Approved.** Không có Phải sửa / Nên sửa. Được làm Phần B sau khi người dùng squash merge PR #5 (tiêu đề
`chore: chuẩn bị phát hành VKey 1.0.2`).

Kiểm tra trên worktree sạch (`git worktree add --detach ../mkey-review 2d9cbf6`, `xcodegen generate`, DerivedData mới):
`scripts/check.sh` ✅ — `14 / 53 / 8 / 6 / 6 / 5` (không đổi). CI (`check`) của `2d9cbf6` xanh ✅. PR vào `main`, không Draft ✅.
- 1 commit đúng tên prompt, cha = `1af69f4` (`origin/main`) ✅.
- `numstat` có / không `-w` khớp đúng: `2 2 | -w 2 2 | Sources/Support/Info.plist`, `16 0 | -w 16 0 | docs/releases/1.0.2.md` ✅.
  Diff `Info.plist` đúng 2 dòng `<string>` (sửa dạng văn bản, không sắp lại khoá) ✅.
- `PlistBuddy` → `1.0.2` / `4` ✅. `docs/releases/1.0.2.md` khớp từng ký tự với bản trong prompt (`diff` rỗng) ✅.
- Nội dung trùng bản Claude đã đo trước (build Release + ký + feed 3 mục + smoke 4/4, PLAN "8b — kế hoạch chi tiết") ✅.

Phần B: `<SHA Review lần 1 ghi>` = **`2d9cbf6`** — `git diff --stat 2d9cbf6 $MERGE -- . ':!docs/reviews'` phải rỗng.

## Kiểm Phần B — tài sản 1.0.2 (Claude, 2026-10-24)
`MERGE` = `2c373fe` (squash PR #5, cây = `2d9cbf6`). Worktree `/Users/duc/Developer/vkey-release-1.0.2` @ `2c373fe`, sạch.
`build/update-1.0.2`: đúng 3 file, SHA-256 khớp báo cáo (`appcast.xml` `44e0e1c4…`, `VKey-1.0.2.zip` `d0993bb9…`,
`VKey-1.0.2.md` `979627e4…`); `sign_update --verify` feed pass; `verify-update-feed.py` → `PASS: archive, feed, release notes
signatures and tamper rejection`; ghi chú = `docs/releases/1.0.2.md` @ `2c373fe`. Feed **3 mục**: `1.0.2` build 4 →
`…/download/v1.0.2/VKey-1.0.2.zip` + `…/VKey-1.0.2.md`, macOS ≥ 14.0; mục `1.0.1` và `1.0.0` **trùng từng byte** feed đang
phát hành. Giải nén zip → app `1.0.2` / `4`, universal, `codesign --verify --deep --strict` pass, team `8C4YAMZSGP`, CDHash
`e8a4ba6185273bd45303c62b4147a7a5a3ccad92` (= `build/release-1.0.2/VKey.app`), DR như 1.0.0 / 1.0.1;
`NSHumanReadableCopyright` mới. Smoke 4/4 (báo cáo; Claude đã chạy cùng quy trình khi đo trước). Không chạy feed cục bộ / bản
`old` (quy trình bản vá). **Sẵn sàng phát hành.**
