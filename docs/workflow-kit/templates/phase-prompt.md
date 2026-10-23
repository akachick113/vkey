# Phase {{N}} — {{Tên phase}}

> Codex · **{{GPT-6 Sol / GPT-6 Luna}}** · effort **{{Medium/High/…}}** ({{1 câu lý do — WORKFLOW §8}}) · nhánh `phase-{{N}}-{{tên}}`

## Bối cảnh
Đọc `AGENTS.md`, `docs/PRODUCT_SPEC.md` (mục {{…}}), `docs/PLAN.md` (Phase {{N}} và **quyết định đã chốt của
{{các phase trước}}**). {{Mockup / tài liệu liên quan.}}

{{Mục tiêu phase trong 2–3 câu. Phase này KHÔNG làm gì.}}

Quy ước đã có, phải theo: {{liệt kê quy ước phát sinh ở các phase trước — lặp lại ở đây dù đã có trong PLAN}};
mở thử mọi màn / endpoint đã sửa; ảnh chụp đính kèm trong PR, không commit; **mở PR** và gửi link.

Hiện trạng đã xem (để bạn khỏi tìm lại):
- {{file X đang làm Y; chỗ Z thiếu W; số liệu cụ thể}}
- {{Repo có sẵn: trích từ `docs/notes/codebase-map.md` — quy ước liên quan, test đỏ sẵn ở vùng này (không phải lỗi của bạn).}}

{{Chỉ khi có repo mẫu — xoá nếu không:}}
Tham khảo (`docs/notes/reference-{{tên}}.md`): `{{owner/repo}}@{{sha}}` — `{{đường dẫn file}}` cho {{phần nào}}
({{link GitHub kèm SHA nếu bạn chạy cloud}}). Cách dùng: {{đọc để hiểu, viết lại theo quy ước của mình / được copy
`file` kèm header license + THIRD_PARTY_NOTICES.md}}. Không lấy: {{…}}.

## Việc 0 — Còn tồn
{{Các mục "Còn tồn" của phase trước, đánh `C1, C2…` (khác cách đánh số của review để khỏi lẫn).}}

## Việc 1 — {{…}}
{{Yêu cầu cụ thể: file nào, hàm nào, hành vi nào, xử lý lỗi nào. Khi có nhiều cách, chọn sẵn một cách và nói lý do.}}

## Việc 2 — {{…}}

## Việc {{k}} — Test
Mỗi ca là **một test riêng**, tên test có số ca:
1. {{ca 1 — đầu vào → kết quả mong đợi}}
2. {{ca 2}}
3. {{ca lỗi / biên}}

## Không được làm
- {{việc của phase sau}}
- Không thêm / nâng dependency ngoài: {{danh sách hoặc "không có"}}.
- Không sửa expectation của test cũ (trừ khi giải thích trong PR). Không push `main`.

## Done khi
- [ ] Cài sạch từ lockfile → `{{CHECK_CMD}}` pass; formatter check pass; CI xanh.
- [ ] Đủ {{x}} ca test ở Việc {{k}}.
- [ ] Kịch bản chạy thật (simulator / `curl`):
  - (a) {{…}}
  - (b) {{…}}
- [ ] PR đã mở vào `main`.

## Khi xong
Commit theo từng bước (Conventional Commits). Push nhánh `phase-{{N}}-{{tên}}`, **mở PR vào `main`** và gửi link.
Trả lời bằng tiếng Việt:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả từng kịch bản (a)–(…).
3. Chỗ nào khác prompt / mockup và lý do.
4. Những chỗ bạn **chưa chắc** hoặc chưa kiểm được (và vì sao).
