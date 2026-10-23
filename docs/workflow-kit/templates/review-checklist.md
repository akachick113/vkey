# Checklist review PR của Codex

Rút từ các review thật (Wakeai Phase 0–7a). Phần **Chung** dùng cho mọi stack; phần **Theo stack** sửa lại cho project mới.
Nguyên tắc: **kiểm bằng cách chạy, không chỉ đọc** — nhiều lỗi chỉ lộ ra khi chạy.

## Chung

**Phạm vi & prompt**
- [ ] Đi qua **từng** Việc, **từng** ca test bắt buộc (grep theo số ca / mô tả). Codex hay gộp nhiều ca vào một test lớn
      hoặc bỏ âm thầm.
- [ ] Test có thể xanh vì lý do sai (vd chuỗi tìm kiếm khớp nhầm trường khác) — đọc assertion, thử làm hỏng code xem
      test có đỏ không.
- [ ] Diff các file test **cũ**: Codex hay sửa expectation cũ cho khớp output mới.
- [ ] Prompt nói "thay X bằng Y" → X cũ đã xoá hết chưa (code chết, module trùng).
- [ ] Không vi phạm `Không được làm`; không tự mở rộng phạm vi.
- [ ] "Tuân thủ giả": vd file re-export 1 dòng để trông như tách file, trong khi file thật vẫn quá dài.
- [ ] PR đã mở chưa (xem cách kiểm trong `WORKFLOW.md` §5 — sort số khi dùng `ls-remote`).

**Môi trường sạch**
- [ ] Review trên worktree mới, cài từ lockfile (`npm ci`), không dùng `node_modules` / build cũ của Codex.
- [ ] Formatter check (`prettier --check .`, `prisma format`…) — Codex hay quên.
- [ ] Lockfile: có bị tạo lại không? Có bản dependency trùng / không hợp lệ không (`npm ls`)?
- [ ] Build không có `.env` vẫn chạy (không side effect lúc import, vd tạo DB client khi build).
- [ ] CI xanh **không đủ**: CI không chạy app thật. Luôn khởi động app từ cài đặt sạch.

**Đúng nghiệp vụ**
- [ ] Ví dụ chuẩn trong spec ra đúng số trên app thật.
- [ ] Ngày / giờ: tính theo lịch địa phương khi domain là ngày địa phương (không UTC). Test không phụ thuộc đồng hồ thật
      (test "bom hẹn giờ" hỏng sau một ngày cụ thể).
- [ ] Tiền / số: không float, không chuỗi thập phân, không default DB âm thầm (= 0).
- [ ] Đầu vào sai định dạng (id không hợp lệ, query lạ) → 400, không 500.
- [ ] Bí mật không lọt ra response / log.

**Thay đổi dùng chung**
- [ ] State / hook dùng chung mới có đè lên luồng cũ không? Chạy lại luồng chính của **các phase trước** chạm tới.
- [ ] Luồng bất đồng bộ / race (đọc state trước khi load xong, nhiều request song song cùng tạo session…).

**Cách viết review**
- [ ] Mỗi mục Phải sửa: hiện tượng → nguyên nhân (file/hàm) → cách sửa → test cần thêm.
- [ ] Lỗi do prompt gây ra → nhận là của prompt, sửa prompt mẫu cho lần sau.
- [ ] Không gợi ý nâng dependency trong review tính năng.
- [ ] Phát hiện kiểu mới → thêm vào memory `codex-review-lessons` (và vào file này khi xong project).

## Kịch bản B / C (WORKFLOW §10–11)

**B — Repo có sẵn làm nền**
- [ ] Test đỏ so với baseline (`docs/notes/codebase-map.md` §4): chỉ test đỏ **mới** tính cho PR; test đỏ sẵn không bị
      "sửa" bằng cách đổi expectation hay xoá.
- [ ] Diff có format lại / đổi tên / di chuyển file ngoài phạm vi không: `git diff --stat origin/main...`, rồi
      `git diff -w --stat origin/main...` — file biến mất khỏi danh sách thứ hai là file chỉ đổi khoảng trắng.
- [ ] Theo quy ước của repo (commit, style, cấu trúc, cách viết test), không theo thói quen của Codex hay mặc định của kit.
- [ ] Đúng package manager + lockfile của repo (không sinh `package-lock.json` trong repo dùng pnpm / yarn…).
- [ ] Code cũ chạm tới vẫn chạy: chạy luồng chính liên quan trên app thật, không chỉ test mới.
- [ ] Fork đóng góp ngược: nhánh tạo từ `upstream/<nhánh chính>`, PR không chứa `docs/workflow-kit`, `prompts`,
      `reviews`, `PLAN`; theo `CONTRIBUTING` của upstream.

**C — Repo khác làm mẫu**
- [ ] Đặt file của PR cạnh file tương ứng trong `_refs/`: có đoạn copy ngoài phạm vi reference note cho phép không?
- [ ] Copy được phép → còn header license, đã ghi vào `THIRD_PARTY_NOTICES.md`.
- [ ] Không kéo theo dependency của repo mẫu ngoài danh sách prompt; không mang API cũ / đã bỏ của phiên bản repo mẫu.
- [ ] Không còn tên app, URL, key, analytics id, đường dẫn của repo mẫu (`grep -ri "<tên repo mẫu>"`).

## Theo stack — React Native / Expo (sửa cho stack mới)

- [ ] Hermes ≠ Node: `Intl` (`DisplayNames`, `formatToParts`, ký hiệu tiền `¥`/`￥`) khác nhau → jest xanh nhưng app crash /
      hiện sai. Mở **mọi màn đã sửa** trên simulator, cả các ngôn ngữ.
- [ ] Fetch bị mock che lỗi nền tảng (upload multipart, FormData). Chạy upload / picker **2 lần** trên simulator và xem log
      API có request thật.
- [ ] Mở native modal / picker khi sheet đang đóng → treo. Đóng sheet trước khi điều hướng.
- [ ] Nâng bản vá Expo có thể làm lồng `expo-router` / trùng `react` → `expo start` crash dù CI xanh.
- [ ] Vùng chạm ≥ 44 pt (bù bằng `hitSlop`, không phình kích thước nhìn thấy); container chữ dùng `minHeight`.
- [ ] Chữ cứng trong component, màu hex ngoài tokens (ESLint flat config: khối sau ghi đè khối trước cùng tên rule).
- [ ] jest tự thoát (không cần `--forceExit`).
- [ ] Deep link: dev build cài sẵn có thể chiếm scheme — chọn rõ Expo Go / dev build khi thử.
