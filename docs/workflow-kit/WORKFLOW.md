# Quy trình làm việc: Người dùng · Claude · Codex

## 1. Vai trò

| Ai | Làm | Không làm |
|---|---|---|
| **Người dùng** | Chốt nghiệp vụ, trả lời câu hỏi, chọn khi có phương án, chuyển lời giữa Claude ↔ Codex, **merge PR** | Không cần đọc từng dòng code |
| **Claude** (planner + reviewer) | Viết spec, plan, prompt từng phase; review bằng cách **chạy** (worktree sạch, simulator, log); ghi quyết định vào `PLAN.md`; giữ memory | Không viết code tính năng (trừ sửa gấp trên `main` khi chặn mọi người, xem §7) |
| **Codex** (implementer) | Code trên nhánh phase, test, mở PR, báo cáo theo mẫu, sửa theo review | Không push `main`, không tự đổi phạm vi, không sửa test cũ cho khớp output mới |

Bàn giao **qua file trong repo và PR**, không dán nội dung dài qua chat. Người dùng chỉ chuyển những câu ngắn kiểu
`Đọc docs/reviews/phase-3.md mục "Review lần 2" và sửa.` — file đó đã được Claude commit + push lên `main`; Codex đọc
bản trên `origin/main` (quy tắc trong `AGENTS.md`), nên chạy local hay cloud đều thấy.

## 2. Tài liệu trong repo

```
AGENTS.md                  quy tắc bắt buộc cho mọi agent (Codex + Claude đều đọc)
CLAUDE.md                  Claude Code tự đọc; import AGENTS.md + WORKFLOW.md
.github/workflows/ci.yml   CI chạy {{CHECK_CMD}} (mẫu: templates/ci.yml)
docs/PRODUCT_SPEC.md       nghiệp vụ — nguồn sự thật về "đúng"
docs/PLAN.md               stack, cấu trúc thư mục, các phase + "Done khi" + "Quyết định đã chốt"
docs/prompts/phase-N.md    prompt giao cho Codex (Claude viết, commit lên main TRƯỚC khi Codex bắt đầu)
docs/reviews/phase-N.md    review của Claude, nhiều vòng nối tiếp trong 1 file
docs/notes/*.md            điều tra kỹ thuật (vd nguyên nhân lỗi nâng cấp dependency)
docs/notes/codebase-map.md repo có sẵn: hiện trạng, baseline, quy ước (§10)
docs/notes/reference-*.md  repo tham khảo: SHA, license, lấy gì / không lấy gì (§11)
docs/workflow-kit/         bản copy của kit này
```

`PLAN.md` là trí nhớ dài hạn của project: mỗi phase merge xong có mục **✅ Xong (PR #n). Quyết định đã chốt (Phase sau
phải theo)** + **Còn tồn**. Prompt phase sau luôn bảo Codex đọc các mục này.

## 3. Vòng lặp mỗi phase

```
Claude viết docs/prompts/phase-N.md ──commit+push main──▶ Người dùng mở session Codex MỚI
        ▲                                                         │ "Đọc docs/prompts/phase-N.md và làm."
        │                                                         ▼
Claude: cập nhật PLAN.md + memory              Codex: nhánh phase-N-<tên>, commit, push, MỞ PR, báo cáo
   trên main, push, viết prompt N+1                               │
        ▲                                                         ▼
Người dùng merge (squash) ◀── Approved ── Claude review (worktree sạch, chạy thật) → docs/reviews/phase-N.md
                                               │ Phải sửa
                                               ▼
                               Người dùng → Codex (CÙNG session): "Đọc … mục Review lần K và sửa."
                               Codex sửa, push cùng nhánh → Claude review lần K+1
```

Chi tiết từng bước:

1. **Prompt** (Claude): theo `templates/phase-prompt.md`. Ghi sẵn hiện trạng đã khảo sát để Codex khỏi tìm lại. Mỗi
   test bắt buộc là một mục đánh số riêng. Có `Không được làm` và `Done khi` kiểm được. Commit
   `docs: add phase N prompt` lên `main`, push.
2. **Code** (Codex): nhánh `phase-N-<tên-ngắn>`, Conventional Commits, `{{CHECK_CMD}}` xanh, **mở PR vào `main`**, trả
   lời theo mục "Khi xong" của prompt (tóm tắt, số test, CI, link PR, kết quả kịch bản, chỗ lệch prompt, chỗ chưa chắc).
3. **Review** (Claude): theo §6. Viết / nối tiếp `docs/reviews/phase-N.md` trên `main`, **commit + push mỗi vòng**
   (`docs: review phase N lần K`) rồi mới báo người dùng. Codex đọc bằng `git fetch origin` +
   `git show origin/main:docs/reviews/phase-N.md` — không cần merge, file review không bao giờ lọt vào PR. Mỗi vòng ghi
   commit SHA đã review.
4. **Sửa** (Codex, cùng session): sửa hết **Phải sửa**, nên sửa **Nên sửa**, push cùng nhánh. Lặp lại bước 3.
5. **Approved** → người dùng merge (squash). Kiểm tra commit squash giống commit đã review.
6. **Chốt** (Claude, trên `main`): cập nhật `PLAN.md` (Quyết định đã chốt, Còn tồn), commit, push. Ghi
   tiến độ vào memory. Viết prompt phase tiếp, bắt đầu bằng `Việc 0 — Còn tồn`.

Phase lớn thì **chia nhỏ** (4a / 4b / 4c): một phase = một nhánh = một PR, review được trong 1–3 vòng.

## 4. Session

**Codex**
- Session **mới cho mỗi phase** (context sạch, chỉ đọc file).
- **Cùng session** khi sửa cùng PR (giữ ngữ cảnh lỗi).
- Nếu Codex không truy cập được simulator / thiết bị (sandbox), Claude tự chạy phần đó khi review; ghi rõ trong review.
- Ghi rõ trong `CLAUDE.md` + memory: Codex chạy **local** (cùng máy, cùng thư mục) hay **cloud**. Codex cloud không thấy
  file chưa push, không thấy `../_refs/` → mọi bàn giao phải commit + push trước khi nhắn Codex.
- Codex local và Claude cùng một thư mục: Claude không đổi nhánh / sửa file ở checkout chính khi Codex đang làm; review
  luôn ở worktree riêng (§6).

**Claude**
- Không cần session mới mỗi phase: trạng thái nằm trong `PLAN.md`, `reviews/`, `prompts/`, memory.
- **Chủ động đề xuất session mới** (không đợi người dùng hỏi) khi: xong một nhóm phase (vd 4a–4c), hoặc session đã qua
  ≥ 2 phase / nhiều ảnh simulator / nhiều vòng review. Kèm câu mở session mới, ví dụ:
  `Tiếp tục {{TÊN_PROJECT}}: Phase N đã merge, đọc docs/PLAN.md và viết prompt Phase N+1.`
- Session mới của Claude cũng dùng cho việc lạc đề (điều tra dependency, việc dọn dẹp) để không làm loãng session review.

## 5. GitHub

- `main` chỉ nhận: tài liệu của Claude (prompt, review, PLAN, notes) và PR đã merge. Codex không push `main`.
  Repo có sẵn: `main` = nhánh chính của repo (có thể là `master` / `develop`); fork đóng góp ngược: xem §10.
- Nhánh: `phase-N-<tên-ngắn>`. Commit: Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`, `chore:`).
- PR: dùng `templates/pull_request_template.md`. Merge kiểu **squash**. Ảnh chụp màn hình đính kèm trong PR, không commit
  (trừ ảnh làm bằng chứng trong review → `docs/reviews/assets/`).
- CI chạy `{{CHECK_CMD}}` trên mỗi PR và push `main`, bắt đầu từ Phase 0.
- Kiểm tra đã có PR chưa:
  - có `gh`: `gh pr list --head <nhánh>`
  - không có `gh`: `git ls-remote origin 'refs/pull/*/head' | sort -t/ -k3 -n | tail` — **phải** sort số, sort chữ làm
    PR #10+ đứng trước #2–9 (đã từng báo nhầm "chưa có PR" 5 lần).
- Không commit `.env*` (trừ `.env.example`), DB, file người dùng, thư mục build / dependency, `_refs/` (mẫu
  `.gitignore`: `templates/gitignore`).
- Trên nhánh phase chỉ stage file đã sửa (`git add <file>`), không `git add -A` / `git add .` — tránh kéo theo file tạm,
  file của Claude, repo tham khảo.

## 6. Review (Claude)

1. Worktree sạch: `git worktree add ../<repo>-review <nhánh>` → cài dependency từ lockfile (`npm ci`…) → không dùng
   `node_modules` / build cũ của Codex.
2. Chạy `{{CHECK_CMD}}`, formatter check, kiểm tra dependency trùng / lockfile thay đổi. Repo có sẵn: so test đỏ với
   baseline trong `docs/notes/codebase-map.md` §4 — chỉ test đỏ **mới** tính cho PR.
3. Đối chiếu prompt: **từng** việc, **từng** test bắt buộc (grep tên ca), `Không được làm`, `Done khi`.
4. **Chạy thật** mọi màn / endpoint bị chạm (simulator, `curl`, log API). Luồng nhạy cảm chạy 2 lần. Chạy lại luồng chính
   của phase trước nếu đổi code dùng chung.
5. Đi qua `templates/review-checklist.md` (cả nhóm "Kịch bản B / C" nếu áp dụng).
6. Ghi file review theo `templates/review.md`: **Phải sửa** (nguyên nhân + cách sửa + test cần thêm), **Nên sửa**,
   **Done khi**. Lỗi do chính prompt gây ra thì nhận là của prompt. Commit + push lên `main` (§3 bước 3).
7. Nói với người dùng: kết luận (Approved / cần sửa), số mục phải sửa, câu để chuyển cho Codex.
8. Dọn: xoá file test tạm, `git worktree remove`.

## 7. Ngoại lệ

- **Lỗi chặn trên `main`** (vd test hỏng theo ngày): Claude sửa nhỏ trực tiếp trên `main`, push, rồi bảo Codex merge
  `main` vào nhánh phase.
- **Nâng dependency**: không làm lẫn trong phase tính năng. Điều tra trước (`docs/notes/`), nâng trong PR riêng chỉ có
  dependency, kiểm bằng cài sạch + chạy app thật.
- **Việc không kiểm được trên simulator** (VoiceOver, thiết bị thật…): ghi vào **Còn tồn** của phase phát hành, không
  chặn phase hiện tại.

## 8. Model & effort của Codex

Đang dùng được: **GPT-6 Sol** và **GPT-6 Luna**, mọi mức effort (cập nhật 10/2026 — đổi model thì sửa mục này).

| | GPT-6 Sol | GPT-6 Luna |
|---|---|---|
| Vị trí | Model chính — mạnh hơn rõ ở việc agent nhiều bước | Model nhẹ — nhanh hơn ~1,5×, rẻ hơn nhiều, hạn mức rộng hơn |
| Điểm yếu | Chậm hơn, tốn hạn mức hơn | Kém hơn rõ khi việc dài / nhiều file, sai sự thật nhiều hơn |
| Effort cao nhất trong Codex | `ultra` | `max` |

(Coding Agent Index chạy trong Codex, mức max: Sol 57, Luna 41 — Artificial Analysis, 9/2026. Mặc định của Codex là
`medium` nếu không chọn.)

| Loại phase / việc | Model · effort |
|---|---|
| Tài liệu, config, CI, `.gitignore`, đổi chữ / i18n, CRUD chép theo mẫu đã có trong repo | **Luna · Medium** |
| Phần lớn phase: màn hình, API thường, test theo danh sách ca — **mặc định** | **Sol · Medium** |
| Logic lõi (tiền, thuật toán), xác thực / phân quyền, migration DB, refactor nhiều file, sửa lỗi khó, Phase 0 của repo có sẵn | **Sol · High** |
| Sol High làm sai 2 lần | **Sol · Max** |
| Sol Max vẫn sai | **Sol · Ultra** — nhưng trước đó xem lại prompt: thường do prompt mơ hồ hoặc phase quá to → chia nhỏ |

Quy tắc:
- Luna chỉ dùng khi phase **nhỏ, rõ, ít rủi ro** và lỗi dễ thấy khi review. Phân vân → Sol.
- Luna làm sai 1 lần → chuyển **Sol · Medium**, không leo effort của Luna (chênh lệch giữa hai model lớn hơn chênh lệch
  giữa các mức effort).
- **Low / None**: không dùng cho phase có test; chỉ cho việc vặt ngoài phase (đổi tên, sửa typo).
- Sửa theo review: giữ model + effort của phase; chỉ nâng khi vòng sửa trước sai. Nâng effort, hoặc nâng Luna → Sol: dùng
  `/model` trong **cùng session** để giữ ngữ cảnh lỗi.
- **Hạ Sol → Luna** (vd hết hạn mức): **không** đổi model giữa session — Luna nhận ngữ cảnh dài của Sol rồi trả lời lạc
  hướng (đã gặp ở Phase 5d). Mở **session Luna mới**; Claude viết trước mục "Hướng dẫn sửa (cho Luna)" trong file review:
  từng bước nhỏ, lệnh / đoạn code cụ thể, kết quả kiểm mong đợi (Claude chạy thử trước trên worktree review). Phần chạy
  thật / chụp ảnh tốn hạn mức → Claude làm khi review.
- Claude chọn model + effort khi viết prompt, ghi ở **dòng đầu** prompt kèm 1 câu lý do. Mỗi lần leo thang ghi vào file
  review ("Vòng 2: Sol High vì …"). Thấy quy luật (vd "Luna hay bỏ ca test") → thêm vào memory `codex-review-lessons`.

## 9. Memory của Claude (tạo ở session đầu)

| Memory | Nội dung |
|---|---|
| `<project>-project` (project) | Repo, tài liệu, tiến độ từng phase (PR #, commit squash, quyết định lớn), kịch bản (mới / repo có sẵn / có tham khảo), Codex chạy local hay cloud |
| `claude-codex-workflow` (user) | Tóm tắt file này: vai trò, vòng lặp, session, model + effort (§8), ngôn ngữ |
| `codex-review-lessons` (feedback) | Lỗi Codex hay mắc **trong project này** — thêm sau mỗi review có phát hiện mới |
| `suggest-new-session` (feedback) | Chủ động đề xuất session mới ở mốc phase |

## 10. Lấy repo có sẵn làm nền (kịch bản B)

Code của repo là nền của app — không xây lại từ đầu. Khác dự án mới ở 5 điểm:

1. **Khảo sát trước, chưa sửa code.** Claude đọc repo, viết `docs/notes/codebase-map.md` (theo
   `templates/codebase-map.md`) tại một commit cụ thể. Mục "Hiện trạng đã xem" của mọi prompt sau trích từ file này.
2. **Baseline.** Cài sạch từ lockfile (đúng package manager, đúng runtime), chạy test / lint / build đang có, ghi kết quả
   và **tên từng test đỏ sẵn**. Không có baseline thì review không phân biệt được lỗi của Codex với lỗi có từ trước.
3. **Quy ước repo > quy ước kit.** Commit, tên nhánh, nhánh chính, kiểu merge, ngôn ngữ tài liệu, formatter, cấu trúc thư
   mục: theo repo. Kit chỉ bổ sung chỗ repo chưa có. Chỗ lệch ghi ở `codebase-map.md` §6 và hỏi người dùng **một lần**.
   `CHECK_CMD` ghép từ lệnh sẵn có, không chế toolchain mới. Repo chưa từng chạy formatter → không format cả repo, chỉ
   format file đã sửa.
4. **Phase 0 = đưa repo về trạng thái xanh**, chỉ khi cần: cài được, test đỏ sẵn sửa hoặc skip có ghi lý do, có CI chạy
   `CHECK_CMD`. Không tính năng, không refactor, không nâng dependency (trừ khi chính nó làm hỏng cài đặt). Baseline đã
   xanh + có CI → bỏ Phase 0, vào Phase 1.
5. **Tài liệu suy ra từ code.** `PRODUCT_SPEC.md` viết ngược từ code; mục suy luận đánh `(suy ra — cần xác nhận)` cho tới
   khi người dùng xác nhận. `AGENTS.md` / `CLAUDE.md` / `CONTRIBUTING` đã có thì **bổ sung**, không ghi đè.

**Git theo nguồn của repo**

| Kiểu | Remote | Làm gì |
|---|---|---|
| Clone làm dự án riêng | `origin` = repo của mình · `upstream` = repo gốc (chỉ fetch) | `git remote rename origin upstream` → tạo repo mới → `git remote add origin <url>` → push. Kiểm license repo gốc (§11) trước khi dùng thương mại / công khai |
| Fork, đóng góp ngược | `origin` = fork · `upstream` = gốc | Xem dưới |
| Repo của team | `origin` | Theo quy trình PR / review của team; kit chỉ dùng phần plan + review |

**Fork đóng góp ngược upstream** — docs quy trình (`docs/workflow-kit`, `prompts`, `reviews`, `PLAN`…) không được lọt
vào PR gửi upstream:
- `main` của fork = `upstream/main` + các commit docs của Claude. Docs chỉ sống ở đây.
- Nhánh phase tạo từ **`upstream/<nhánh chính>`**, không từ `main` của fork. PR mở vào upstream (hoặc vào fork để
  review trước, rồi mở lại vào upstream).
- Codex đọc `AGENTS.md`, prompt, review bằng `git show origin/main:<file>` (nhánh phase không có các file này).
- Đồng bộ: `git fetch upstream && git checkout main && git merge upstream/<nhánh chính>`, push `origin main`.
- Theo `CONTRIBUTING` của upstream (CLA, kiểu commit, issue trước khi PR…) — ưu tiên hơn mọi quy ước của kit.

## 11. Dùng repo khác làm mẫu (kịch bản C)

Repo của mình bắt đầu trống, tự viết mới; repo mẫu chỉ để đọc, không bao giờ thành code của mình. Muốn giữ phần lớn code
của họ → dùng §10. Bảng chọn B hay C: README mục "Chọn B hay C".

1. **Clone ra ngoài repo của mình:** `git clone --depth 1 <url> ../_refs/<tên>`, ghi SHA:
   `git -C ../_refs/<tên> rev-parse HEAD`. (Hoặc trong repo nhưng `_refs/` có trong `.gitignore`.) Codex cloud không thấy
   `../_refs/` → prompt ghi link GitHub **kèm SHA** tới đúng file.
2. **Chưa chạy code của repo mẫu.** Không `npm install` / `make` / script trước khi đọc `package.json` (`postinstall`,
   `prepare`), Makefile, Dockerfile. Cần chạy thì chạy trong container / máy ảo nếu có.
3. **Kiểm license** (file `LICENSE`, trường `license` trong manifest, header file):

   | License | Copy code vào dự án | Điều kiện |
   |---|---|---|
   | MIT / BSD / ISC | Được | Giữ thông báo bản quyền + nội dung license |
   | Apache-2.0 | Được | Giữ `NOTICE`, ghi rõ file đã sửa |
   | MPL-2.0 | Được, theo từng file | File copy vẫn theo MPL; phân phối thì phải mở mã các file đó |
   | GPL / AGPL | Hạn chế | Copy vào → cả dự án phải theo GPL (AGPL: kể cả khi chỉ chạy làm dịch vụ mạng). Dự án đóng → chỉ học ý tưởng |
   | Không có license | Không | Mặc định tác giả giữ mọi quyền → chỉ học ý tưởng, tự viết lại |

   Bảng này để định hướng, không phải tư vấn pháp lý; dự án thương mại quan trọng thì hỏi người có chuyên môn.
4. **Ghi `docs/notes/reference-<tên>.md`** (theo `templates/reference.md`): lấy gì, ở đâu, lấy kiểu gì (ý tưởng / viết
   lại / copy kèm ghi nguồn), không lấy gì, khác biệt bối cảnh. Người dùng duyệt danh sách trước khi viết PLAN.
5. **Trong prompt phase**, mục "Tham khảo" ghi file + SHA + cách lấy. Mặc định: *đọc để hiểu, viết lại theo quy ước của
   mình*. Copy chỉ khi reference note cho phép, kèm header license + `THIRD_PARTY_NOTICES.md`.
6. **Không kéo theo** dependency, phiên bản cũ, tên app, URL, key, analytics id của repo mẫu. Review kiểm theo nhóm
   "C — Repo khác làm mẫu" trong checklist.
