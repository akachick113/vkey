# Tham khảo: {{owner/repo}}

| | |
|---|---|
| Link | {{https://github.com/owner/repo}} |
| Commit đã xem | `{{sha}}` ({{YYYY-MM-DD}}) — link file luôn kèm SHA này, không trỏ vào nhánh |
| Clone ở | `{{../_refs/<tên>}}` (**ngoài** repo của mình, hoặc `_refs/` có trong `.gitignore`) |
| License | {{MIT / Apache-2.0 / GPL-3.0 / không có…}} → {{được copy kèm ghi nguồn / chỉ học ý tưởng}} (WORKFLOW §11) |
| Lý do tham khảo | {{1–2 câu}} |

## Lấy gì
| Phần | Ở đâu trong repo mẫu | Cách lấy | Dùng ở phase |
|---|---|---|---|
| {{kiến trúc thư mục}} | `{{path}}` | ý tưởng | {{0}} |
| {{cách xử lý X}} | `{{path/file#Lx-Ly}}` | viết lại theo quy ước mình | {{3}} |
| {{hàm tiện ích Y}} | `{{path/file}}` | copy kèm ghi nguồn (chỉ khi license cho phép) | {{2}} |

Cách lấy có 3 mức: **ý tưởng** (không nhìn code khi viết) · **viết lại** (đọc để hiểu, viết theo quy ước của mình) ·
**copy kèm ghi nguồn** (giữ header license, ghi vào `THIRD_PARTY_NOTICES.md`).

## Không lấy (và vì sao)
- {{phần X — quá phức tạp so với v1 / phụ thuộc dịch vụ mình không dùng / license không cho phép}}

## Khác biệt bối cảnh
{{Repo mẫu khác mình ở đâu: phiên bản framework, quy mô, nền tảng, yêu cầu bảo mật… → phải điều chỉnh gì khi áp dụng.}}

## Rủi ro
- Dependency cũ / đã bỏ: {{…}}
- Code chưa có test / có issue mở liên quan: {{…}}
- Script cài đặt đáng chú ý (`postinstall`, `prepare`, Makefile, Dockerfile): {{đã đọc — an toàn / chưa chạy}}

## Ghi nguồn (chỉ khi copy)
| File của mình | Nguồn (file@sha) | License | Đã ghi header / NOTICE |
|---|---|---|---|
| | | | |
