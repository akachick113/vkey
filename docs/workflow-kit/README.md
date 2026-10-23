# Bộ khung quy trình: Claude lập kế hoạch + review, Codex viết code

Đúc kết từ dự án Wakeai (Phase 0 → 7a). Dùng cho 3 kịch bản: **dự án mới**, **lấy repo có sẵn làm nền** (clone /
fork rồi sửa tiếp), **viết mới, chỉ dùng repo khác làm mẫu**. Chọn kịch bản bên dưới, copy kit vào repo, sửa `{{…}}` trong prompt tương
ứng và dán vào session Claude đầu tiên.

| File | Dùng để |
|---|---|
| [`WORKFLOW.md`](./WORKFLOW.md) | Quy trình đầy đủ: vai trò, vòng lặp mỗi phase, session, GitHub, chọn model + effort, review |
| [`templates/AGENTS.md`](./templates/AGENTS.md) | Quy tắc cho AI agent — đặt ở gốc repo mới |
| [`templates/PRODUCT_SPEC.md`](./templates/PRODUCT_SPEC.md) | Khung tài liệu nghiệp vụ → `docs/` |
| [`templates/PLAN.md`](./templates/PLAN.md) | Khung kế hoạch theo phase + chỗ ghi quyết định → `docs/` |
| [`templates/phase-prompt.md`](./templates/phase-prompt.md) | Khung prompt giao cho Codex mỗi phase → `docs/prompts/` |
| [`templates/review.md`](./templates/review.md) | Khung file review mỗi phase → `docs/reviews/` |
| [`templates/review-checklist.md`](./templates/review-checklist.md) | Checklist review (lỗi Codex hay mắc) |
| [`templates/pull_request_template.md`](./templates/pull_request_template.md) | → `.github/` |
| [`templates/CLAUDE.md`](./templates/CLAUDE.md) | Để Claude Code đọc `AGENTS.md` + `WORKFLOW.md` → gốc repo |
| [`templates/ci.yml`](./templates/ci.yml) | CI chạy `CHECK_CMD` → `.github/workflows/` |
| [`templates/gitignore`](./templates/gitignore) | → `.gitignore` |
| [`templates/codebase-map.md`](./templates/codebase-map.md) | Kịch bản B: khảo sát + baseline repo có sẵn → `docs/notes/` |
| [`templates/reference.md`](./templates/reference.md) | Kịch bản C: ghi repo tham khảo (SHA, license, lấy gì) → `docs/notes/reference-<tên>.md` |

## Chọn kịch bản

| Kịch bản | Code chạy trong app là của ai | Khi nào | Bắt đầu thế nào |
|---|---|---|---|
| **A. Dự án mới** | Của bạn, viết từ đầu | Chưa có gì | Claude viết spec + plan, Phase 0 = khởi tạo repo |
| **B. Lấy repo có sẵn làm nền** | Của họ + phần bạn sửa | Clone / fork rồi sửa tiếp, push lên repo của mình; fork đóng góp ngược; repo của team / repo cũ của bạn | **Không xây lại.** Claude khảo sát + chạy thử. Repo chưa chạy được → Phase 0 sửa cho xanh; chạy được rồi → vào thẳng tính năng (WORKFLOW §10) |
| **C. Viết mới, chỉ dùng repo khác làm mẫu** | Của bạn, viết từ đầu | Muốn học kiến trúc / giao diện / cách làm của repo khác nhưng app là của mình | Như A. Repo mẫu clone ra ngoài (`../_refs/`) **chỉ để đọc**, kiểm license, ghi lấy gì / không lấy gì (WORKFLOW §11) |

Cả B và C đều clone repo người khác, nhưng khác **mục đích**: B clone để **làm nền**, repo đó chính là app của bạn.
C clone để **đọc**, repo đó chỉ là tài liệu, code của bạn viết mới từ đầu.

### Chọn B hay C

Luôn là **B** khi: fork để đóng góp ngược cho repo gốc, hoặc repo của team / repo cũ của chính bạn.
Chỉ phải cân nhắc khi lấy repo **người khác** về làm app **của mình**:

| Nghiêng về B (làm nền) | Nghiêng về C (làm mẫu) |
|---|---|
| Repo đã làm được phần lớn thứ bạn cần, bạn chỉ thêm / sửa | Chỉ cần ý tưởng, kiến trúc hoặc giao diện; app của bạn khác nhiều |
| Repo lớn, trưởng thành, viết lại mất hàng tháng (bán hàng, editor, CMS…) | Repo nhỏ, viết lại cùng AI chỉ vài phase |
| Muốn tiếp tục nhận cập nhật / bản vá bảo mật từ repo gốc | Repo bỏ hoang, code rối, hoặc stack khác hẳn cái bạn muốn |
| License thoáng (MIT, Apache) | License hạn chế (GPL mà bạn muốn đóng mã) hoặc **không có license** — gần như chỉ được làm C |

Quy tắc nhanh — ước lượng sẽ **giữ lại bao nhiêu % code** của họ: trên ~60% → **B**; dưới ~30% → **C**; ở giữa → xem
chất lượng code và có cần cập nhật từ repo gốc không.

Cách lai: **C + copy vài module** (license cho phép, ghi ở `reference.md` mức "copy kèm ghi nguồn"), hoặc **B rồi thay
dần** (mỗi phase thay một phần bằng code của mình).

B và C kết hợp được (repo có sẵn + tham khảo thêm repo khác): dùng prompt B, thêm dòng `Tham khảo:` và bước 1–2 của
prompt C vào đầu "Việc đầu tiên".

**Copy kit vào repo** (cả 3 kịch bản):

```bash
mkdir -p <repo>/docs && rsync -a --exclude .DS_Store ~/Desktop/workflow-kit/ <repo>/docs/workflow-kit/
```

Phần chung cho mọi prompt bên dưới — giữ nguyên trong mỗi prompt:

```text
- Bạn (Claude) = người lập kế hoạch + reviewer. Codex (GPT-6 Sol / GPT-6 Luna, mọi mức effort — chọn theo WORKFLOW §8,
  chạy {{local trên máy này / cloud}}) = người viết code. Tôi = người quyết định và merge PR.
- Giao tiếp với tôi bằng tiếng Việt. Tài liệu trong repo viết bằng {{tiếng Việt / ngôn ngữ repo đang dùng}}.
- Lưu cách làm việc này vào memory của project (vai trò, vòng lặp, quy tắc session, checklist review, kịch bản đang dùng,
  Codex chạy ở đâu) để các session sau không cần nhắc lại.
```

## A. Dự án mới (≈ 15 phút)

1. Tạo thư mục + `git init`, tạo repo GitHub (private), push commit rỗng lên `main`.
2. Copy kit vào `docs/workflow-kit/` (lệnh ở trên).
3. Mở session Claude trong thư mục đó, dán prompt A (đã sửa `{{…}}`).
4. Trả lời các câu Claude hỏi → Claude viết `PRODUCT_SPEC.md`, `PLAN.md`, `AGENTS.md`, `CLAUDE.md`, `.gitignore`,
   prompt Phase 0 và commit lên `main`.
5. Mở session Codex mới: `Đọc docs/prompts/phase-0.md và làm.` Từ đây theo vòng lặp trong `WORKFLOW.md`.

```text
Tôi bắt đầu project mới: {{TÊN_PROJECT}} — {{MÔ_TẢ_1_CÂU}}.
Repo: {{OWNER}}/{{REPO}} (private), thư mục {{ĐƯỜNG_DẪN_LOCAL}}.
Nền tảng: {{iOS / Android / Web / API…}}. Stack mong muốn (nếu có): {{STACK hoặc "bạn đề xuất"}}.
Tài liệu / thiết kế sẵn có: {{link mockup, file, ảnh… hoặc "chưa có"}}.

Cách làm việc: đọc docs/workflow-kit/WORKFLOW.md và làm theo đúng quy trình đó.
{{PHẦN CHUNG}}

Việc đầu tiên:
1. Hỏi tôi những gì còn thiếu để viết spec (tối đa 1 lượt hỏi, gom câu hỏi lại).
2. Viết docs/PRODUCT_SPEC.md, docs/PLAN.md (chia phase nhỏ, mỗi phase một PR, có "Done khi"), AGENTS.md, CLAUDE.md,
   .gitignore — dùng khung trong docs/workflow-kit/templates/.
3. Viết docs/prompts/phase-0.md theo khung phase-prompt.md (Phase 0 gồm CI theo templates/ci.yml).
4. Commit lên main, push, rồi đưa tôi câu để mở session Codex.
```

## B. Lấy repo có sẵn làm nền (clone / fork rồi sửa tiếp)

Code của họ là nền của app — **không xây lại từ đầu**. Repo đã chạy được thì bỏ Phase 0, vào thẳng tính năng bạn muốn.

1. Lấy repo về:
   - **Làm dự án riêng từ repo người khác:** `git clone <url>` → `git remote rename origin upstream` → tạo repo GitHub
     của mình → `git remote add origin <url của mình>` → `git push -u origin <nhánh chính>`.
   - **Fork để đóng góp ngược:** fork trên GitHub → clone fork → `git remote add upstream <url gốc>`.
   - **Repo của mình / của team:** `git clone <url>`.
2. Copy kit vào `docs/workflow-kit/`.
3. Mở session Claude, dán prompt B. Claude **chỉ khảo sát**, chưa sửa code → viết `docs/notes/codebase-map.md`, hỏi
   bạn một lượt (gồm các chỗ quy ước repo lệch kit).
4. Claude viết spec (suy ra từ code), plan từ hiện trạng, bổ sung `AGENTS.md` / `CLAUDE.md`, prompt Phase 0 (đưa repo về
   xanh) hoặc Phase 1 nếu repo đã xanh.
5. Mở session Codex như kịch bản A.

```text
Tôi lấy một repo có sẵn làm nền để sửa tiếp (không viết lại từ đầu): {{TÊN_PROJECT}}.
Nguồn: {{URL repo gốc}} — {{clone làm dự án riêng / fork để đóng góp ngược / repo của tôi hoặc team}}.
Repo làm việc: {{OWNER}}/{{REPO}}, thư mục {{ĐƯỜNG_DẪN_LOCAL}}, nhánh chính {{main / master / develop}}.
Mục tiêu: {{muốn thêm / sửa / mở rộng gì}}.
Tài liệu sẵn có ngoài repo: {{… hoặc "không có"}}.

Cách làm việc: đọc docs/workflow-kit/WORKFLOW.md (đặc biệt §10 Lấy repo có sẵn làm nền) và làm theo đúng quy trình đó.
{{PHẦN CHUNG}}
- Quy ước của repo (commit, nhánh, kiểu merge, ngôn ngữ docs, style) ưu tiên hơn quy ước của kit. Chỗ nào lệch thì
  liệt kê và hỏi tôi một lần.

Việc đầu tiên — KHẢO SÁT, chưa sửa code:
1. Đọc repo, viết docs/notes/codebase-map.md theo templates/codebase-map.md. Có baseline: cài sạch từ lockfile, chạy
   test / lint / build hiện có, ghi tên từng test đỏ sẵn.
2. Hỏi tôi những gì còn thiếu (1 lượt, gom câu hỏi), kèm bảng quy ước lệch kit.
3. Viết docs/PRODUCT_SPEC.md (mục suy ra từ code đánh "(suy ra — cần xác nhận)"), docs/PLAN.md bắt đầu từ hiện trạng.
   AGENTS.md / CLAUDE.md / .gitignore: repo đã có thì bổ sung, không ghi đè.
4. Baseline chưa xanh hoặc chưa có CI → viết docs/prompts/phase-0.md "Đưa repo về trạng thái xanh". Đã xanh → viết
   prompt Phase 1.
5. Commit tài liệu lên {{nhánh chính / main của fork}}, push, rồi đưa tôi câu để mở session Codex.
```

## C. Viết mới, chỉ dùng repo khác làm mẫu

Repo của bạn bắt đầu **trống**; repo mẫu chỉ để đọc, không bao giờ thành code của bạn. Muốn giữ phần lớn code của họ →
dùng B.

1. Như A bước 1–2.
2. Dán prompt C. Claude clone repo mẫu ra **ngoài** repo của bạn, kiểm license, viết
   `docs/notes/reference-<tên>.md` → bạn duyệt danh sách lấy / không lấy.
3. Tiếp như A bước 4–5. Prompt các phase có mục "Tham khảo" chỉ đúng file + SHA.

```text
Tôi bắt đầu project mới: {{TÊN_PROJECT}} — {{MÔ_TẢ_1_CÂU}}.
Repo: {{OWNER}}/{{REPO}} (private), thư mục {{ĐƯỜNG_DẪN_LOCAL}}.
Nền tảng: {{…}}. Stack mong muốn: {{… hoặc "theo repo tham khảo nếu hợp lý"}}.
Tham khảo: {{URL repo mẫu}} — muốn học / mượn: {{kiến trúc / UI / cách làm X / toàn bộ khung}}.
Code do mình viết mới; repo mẫu chỉ để đọc, không lấy làm nền.
Dự án của tôi sẽ: {{đóng mã / mở mã, có thương mại không}} (để xét license).

Cách làm việc: đọc docs/workflow-kit/WORKFLOW.md (đặc biệt §11 Dùng repo khác làm mẫu) và làm theo đúng quy trình đó.
{{PHẦN CHUNG}}

Việc đầu tiên:
1. Clone repo mẫu vào {{../_refs/<tên>}} (ngoài repo của tôi), ghi commit SHA. Chưa chạy install / script của repo mẫu.
2. Kiểm license, đọc phần cần tham khảo, viết docs/notes/reference-<tên>.md theo templates/reference.md.
3. Hỏi tôi những gì còn thiếu (1 lượt), kèm đề xuất lấy gì / không lấy gì và vì sao.
4. Viết docs/PRODUCT_SPEC.md, docs/PLAN.md (có mục "Tham khảo": phase nào dùng gì), AGENTS.md, CLAUDE.md, .gitignore.
5. Viết docs/prompts/phase-0.md, commit lên main, push, rồi đưa tôi câu để mở session Codex.
```

## Những chỗ cần sửa khi dùng lại

- `{{…}}` trong prompt khởi động và trong `templates/` (`{{PHẦN CHUNG}}` = khối "Phần chung" ở trên). Trong
  `templates/ci.yml`, `${{ … }}` là cú pháp GitHub Actions — giữ nguyên.
- `WORKFLOW.md` §8 **Model & effort**: sửa bảng khi có model Codex mới hoặc đổi công cụ.
- `templates/review-checklist.md`: giữ phần chung, xoá / thay phần theo stack (JS/Expo) cho phù hợp stack mới.
- Sau mỗi project, chép bài học mới từ memory `codex-review-lessons` vào `review-checklist.md` ở đây.
- Repo có sẵn có bài học riêng (quy ước lạ, baseline đỏ…) → ghi vào nhóm "Kịch bản B / C" của
  `review-checklist.md`.
