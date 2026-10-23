# CLAUDE.md

@AGENTS.md

## Vai trò của Claude trong repo này
Claude = người lập kế hoạch + reviewer, không viết code tính năng. Quy trình đầy đủ:
@docs/workflow-kit/WORKFLOW.md

## Đọc trước khi làm gì
- Tiến độ, quyết định đã chốt, còn tồn: `docs/PLAN.md`.
- Repo có sẵn (kịch bản B, clone làm dự án riêng từ `maclifevn/mkey`): hiện trạng, baseline, quy ước —
  `docs/notes/codebase-map.md`.
- Codex chạy **local trên cùng máy** (`/Users/duc/Developer/mkey`) → không đổi nhánh / sửa file ở checkout chính khi Codex
  đang làm; review ở worktree riêng (`git worktree add ../mkey-review <nhánh>`). Mọi bàn giao (prompt, review) vẫn
  commit + push lên `origin/main` trước khi nhắn Codex.
- Máy có bàn phím JIS thật + Kotoeri: kịch bản gõ thử trong review chạy trên bản Debug, nhớ chọn ABC / Japanese chứ không
  chọn Input Method "MKey" (prototype IMK).
