# {{TÊN_PROJECT}} — Kế hoạch xây dựng (giao cho Codex)

Đọc trước: [`PRODUCT_SPEC.md`](./PRODUCT_SPEC.md) (nghiệp vụ), [`../AGENTS.md`](../AGENTS.md) (quy tắc code).

Làm **từng Phase một**, mỗi Phase một nhánh + PR. Xong Phase phải đạt "Done khi" rồi mới sang Phase sau.

---

## Stack
<!-- Repo có sẵn: ghi đúng hiện trạng theo notes/codebase-map.md, đánh dấu (định đổi) ở chỗ sẽ thay. -->

| Phần | Chọn |
|---|---|
| {{Repo}} | {{monorepo / single}} |
| {{Client}} | {{…}} |
| {{API}} | {{…}} |
| {{DB}} | {{…}} |
| Test | {{…}} |
| CI | GitHub Actions: `{{CHECK_CMD}}` trên mỗi PR |

## Cấu trúc thư mục đích

```
{{cây thư mục}}
```

## Tham khảo
<!-- Chỉ khi có repo mẫu (WORKFLOW §11). Xoá mục này nếu không có. -->

| Repo | Commit | License | Cách lấy | Dùng ở phase |
|---|---|---|---|---|
| [{{owner/repo}}](./notes/reference-{{tên}}.md) | `{{sha}}` | {{…}} | {{ý tưởng / viết lại / copy kèm ghi nguồn}} | {{…}} |

---

## Phase 0 — Khởi tạo repo
- Khung project, lint + format + typecheck, `{{CHECK_CMD}}`, CI, `.env.example`, README "Chạy ở máy".

Prompt chi tiết: [`prompts/phase-0.md`](./prompts/phase-0.md).

**Done khi:** clone sạch → cài dependency → `{{CHECK_CMD}}` pass trên máy và trên CI.

<!-- Sau khi merge, Claude thêm ngay dưới phase: -->
<!--
Review: [`reviews/phase-0.md`](./reviews/phase-0.md).

**✅ Xong (PR #1).** Quyết định đã chốt (Phase sau phải theo):
- {{quyết định kỹ thuật / quy ước phát sinh khi làm}}
- Còn tồn, làm đầu Phase 1: {{…}}
-->

<!-- REPO CÓ SẴN (WORKFLOW §10): thay Phase 0 ở trên bằng khối dưới. Baseline đã xanh + có CI → bỏ Phase 0. -->
<!--
## Phase 0 — Đưa repo về trạng thái xanh
Hiện trạng: [`notes/codebase-map.md`](./notes/codebase-map.md) (khảo sát tại commit {{sha}}).
- Cài sạch đúng package manager / runtime; test đỏ sẵn: sửa, hoặc skip kèm lý do + link issue; CI chạy `{{CHECK_CMD}}`.
- Không: tính năng mới, refactor, format lại cả repo, nâng dependency (trừ khi chính nó làm hỏng cài đặt).

**Done khi:** clone sạch → cài → `{{CHECK_CMD}}` pass trên máy và CI; mọi test skip có lý do ghi trong PR.
-->

## Phase 1 — {{Logic lõi thuần, có test đầy đủ}}
- {{…}}

**Done khi:** {{…}}

## Phase 2 — {{API / dữ liệu}}
<!-- Phase lớn → chia 2a / 2b / 2c, mỗi phần một PR. -->

## Phase 3 — {{Design system / component}}

## Phase 4 — {{Màn hình / tính năng chính}}

## Phase 5 — {{Tính năng đặc biệt}}

## Phase 6 — Hoàn thiện
- Trạng thái tải / lỗi / rỗng, i18n, accessibility, chế độ demo.

## Phase 7 — Phát hành
- 7a: cấu hình build, icon, id ứng dụng · 7b: {{nền tảng thêm}} · 7c: hạ tầng thật, deploy, thiết bị thật.
