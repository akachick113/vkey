# AGENTS.md — quy tắc cho AI coding agent (Codex, Claude…)

## Bối cảnh
{{TÊN_PROJECT}} là {{MÔ_TẢ_1_CÂU}}. Nghiệp vụ: `docs/PRODUCT_SPEC.md`. Thứ tự công việc: `docs/PLAN.md`.
Prompt từng phase: `docs/prompts/phase-N.md`. Review: `docs/reviews/phase-N.md`.
{{Giao diện: `docs/design/…` — mockup tham chiếu (kích thước, màu, chữ); viết lại bằng component của app, không copy.}}
{{Repo có sẵn: hiện trạng, baseline, quy ước — `docs/notes/codebase-map.md`.}}
{{Có repo tham khảo: `docs/notes/reference-*.md`.}}

## Quy tắc bắt buộc
<!-- Giữ các quy tắc chung, thêm quy tắc riêng của domain (vd tiền là số nguyên, múi giờ…). Mỗi quy tắc phải kiểm được. -->
1. Làm đúng phạm vi prompt của phase. Thấy cần làm thêm → ghi vào báo cáo PR, không tự làm.
2. Không push `main`. Mỗi phase một nhánh `phase-N-<tên>`, Conventional Commits, **mở PR** và gửi link.
3. Không sửa expectation của test cũ cho khớp output mới nếu không giải thích trong PR.
4. Mỗi ca test bắt buộc trong prompt là **một test riêng**, tên test nhắc tới số ca.
5. Không thêm / nâng dependency ngoài danh sách trong prompt. Không tạo lại lockfile.
6. Bí mật (token, khoá, mật khẩu) không bao giờ trả về client, không log, không commit. Không commit `.env*` (trừ
   `.env.example`).
7. {{Quy tắc domain 1 — vd: tiền là số nguyên đơn vị nhỏ nhất, mọi phép chia đi qua `packages/core`.}}
8. {{Quy tắc bảo mật — vd: danh tính người gọi chỉ lấy từ token, không tin id gửi từ client.}}
9. {{Quy tắc UI — vd: mọi chuỗi qua i18n; màu / cỡ chữ chỉ lấy từ tokens; màn hình ≤ 300 dòng, logic tách ra hook.}}
10. Mỗi thay đổi: chạy `{{CHECK_CMD}}` và formatter check, đảm bảo pass trước khi kết thúc. Màn / endpoint đã sửa phải
    được chạy thử thật (simulator, `curl`). Không chạy được (sandbox) → ghi vào mục "chưa kiểm được" của báo cáo.
11. Prompt, review, `PLAN.md` luôn đọc bản mới nhất trên `origin/main` (repo có sẵn: nhánh chính của repo):
    `git fetch origin` rồi `git show origin/main:docs/reviews/phase-N.md`. Không cần merge `main` vào nhánh phase để đọc.
12. Trên nhánh phase chỉ stage file mình sửa (`git add <file>`), không `git add -A` / `git add .`. Không commit
    `docs/prompts/`, `docs/reviews/`, `_refs/`.
13. {{Repo có sẵn:}} theo quy ước ở `docs/notes/codebase-map.md` §6 (ưu tiên hơn quy ước của file này khi lệch). Không
    format lại / đổi tên / di chuyển file ngoài phạm vi. Không tự sửa test đỏ sẵn ở baseline trừ khi prompt giao.
14. {{Có repo tham khảo:}} chỉ dùng theo mục "Tham khảo" của prompt. Mặc định đọc để hiểu rồi viết lại; chỉ copy khi
    prompt cho phép, kèm header license và ghi vào `THIRD_PARTY_NOTICES.md`. Không kéo theo dependency, tên, URL, key
    của repo mẫu.

## Lệnh
- `{{DEV_CMD}}` — chạy môi trường dev.
- `{{CHECK_CMD}}` — lint + typecheck + test toàn repo.

## Báo cáo
Trả lời bằng tiếng Việt theo mục "Khi xong" của prompt phase.
