# Bản đồ codebase — {{owner/repo}}

> Khảo sát tại commit `{{sha}}` (nhánh `{{nhánh chính}}`), ngày {{YYYY-MM-DD}}. Claude viết ở bước khảo sát, **trước khi
> sửa code**. Prompt các phase sau trích "Hiện trạng" từ file này. Cập nhật khi một phase đổi kiến trúc / lệnh / quy ước.

## 1. Tổng quan
- Repo làm gì (3–5 dòng). Ai dùng. Trạng thái: còn được bảo trì? commit gần nhất {{…}}.
- Nguồn: {{clone làm dự án riêng / fork đóng góp ngược / repo của team}}. License: {{…}} (xem WORKFLOW §11 nếu không
  phải repo của mình).

## 2. Stack & môi trường
| Phần | Hiện trạng | Lấy từ đâu |
|---|---|---|
| Ngôn ngữ / framework | {{…}} | {{package.json, go.mod…}} |
| Package manager | {{npm / pnpm / yarn / …}} | lockfile `{{…}}` |
| Runtime | {{Node 20.x…}} | {{.nvmrc / .tool-versions / engines}} |
| DB / dịch vụ ngoài | {{…}} | {{…}} |
| Biến môi trường cần | {{tên biến — không ghi giá trị}} | {{.env.example / grep code}} |

## 3. Lệnh
| Việc | Lệnh | Ghi chú |
|---|---|---|
| Cài | `{{…}}` | từ lockfile, không tạo lại |
| Dev | `{{…}}` | |
| Test | `{{…}}` | |
| Lint / typecheck | `{{…}}` | |
| Format check | `{{…}}` | repo chưa từng format → **không** bật cho cả repo |
| Build | `{{…}}` | |

**`CHECK_CMD` đề xuất:** `{{ghép từ các lệnh sẵn có, không chế toolchain mới}}`

## 4. Baseline (cài sạch từ lockfile, chưa sửa gì)
| Lệnh | Kết quả | Ghi chú |
|---|---|---|
| Cài | ✅/❌ | {{cảnh báo, peer deps…}} |
| Test | {{x pass / y fail / z skip}} | |
| Lint / typecheck | ✅/❌ ({{số lỗi}}) | |
| Build / chạy app | ✅/❌ | |

Test đỏ sẵn (review chỉ tính test đỏ **mới**):
- `{{tên test}}` — {{nguyên nhân nếu biết}}

## 5. Cấu trúc & luồng chính
```
{{cây thư mục rút gọn, 2–3 tầng, ghi chú mỗi thư mục}}
```
- Điểm vào: {{main, router, handler…}}
- Luồng chính: {{request / thao tác → module → DB → response}}
- Module lõi & chỗ phức tạp / rủi ro: {{…}}
- Test đang viết thế nào: {{framework, đặt ở đâu, mock gì}}

## 6. Quy ước đang dùng
| Mục | Repo đang làm | Kit mặc định | Chọn |
|---|---|---|---|
| Commit | {{từ `git log --oneline -30`}} | Conventional Commits | {{repo / kit — hỏi người dùng}} |
| Nhánh chính / tên nhánh | {{…}} | `main` / `phase-N-<tên>` | |
| Merge PR | {{squash / merge / rebase}} | squash | |
| Ngôn ngữ tài liệu | {{…}} | tiếng Việt | |
| Style / formatter | {{config}} | {{…}} | |
| Cấu trúc thư mục | {{…}} | theo PLAN | |

Nguyên tắc: **quy ước repo > quy ước kit**. Kit chỉ bổ sung chỗ repo chưa có.

## 7. Tài liệu & quy tắc AI sẵn có
| File | Có? | Xử lý |
|---|---|---|
| README / CONTRIBUTING | | giữ, trích lệnh |
| AGENTS.md / CLAUDE.md / .cursorrules / .github/copilot-instructions.md | | bổ sung, không ghi đè |
| Template PR / issue | | dùng của repo nếu có |

## 8. CI / CD hiện tại
{{Workflow nào, chạy gì, đang xanh hay đỏ, deploy ở đâu.}}

## 9. Nợ kỹ thuật & rủi ro
- Dependency cũ / có lỗ hổng: {{`npm audit` / `npm outdated` tóm tắt — chỉ ghi, không nâng trong phase tính năng}}
- Thiếu test ở: {{…}}
- Bí mật từng bị commit? {{kiểm sơ `git log -p -S "API_KEY"` hoặc công cụ quét — nếu có thì báo người dùng ngay}}
- {{TODO / FIXME lớn, code chết…}}

## 10. Câu hỏi cho người dùng
1. {{…}}
