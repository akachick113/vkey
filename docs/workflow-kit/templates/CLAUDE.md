# CLAUDE.md

<!-- Đặt ở gốc repo. Claude Code tự đọc file này; AGENTS.md là quy ước của Codex — import để Claude cũng đọc.
     Repo đã có CLAUDE.md: thêm các dòng dưới vào cuối, không ghi đè. -->

@AGENTS.md

## Vai trò của Claude trong repo này
Claude = người lập kế hoạch + reviewer, không viết code tính năng. Quy trình đầy đủ:
@docs/workflow-kit/WORKFLOW.md

## Đọc trước khi làm gì
- Tiến độ, quyết định đã chốt, còn tồn: `docs/PLAN.md`.
- {{Repo có sẵn: hiện trạng, baseline, quy ước — `docs/notes/codebase-map.md`.}}
- {{Có repo tham khảo: `docs/notes/reference-*.md`.}}
- Codex chạy {{local trên cùng máy / trên cloud}} → mọi bàn giao (prompt, review) phải commit + push trước khi nhắn Codex.
