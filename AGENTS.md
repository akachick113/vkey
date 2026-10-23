# AGENTS.md — quy tắc cho AI coding agent (Codex, Claude…)

## Bối cảnh
VKey là bộ gõ tiếng Việt cho macOS (engine OpenKey C++ + CGEventTap + SwiftUI, dựa trên mkey), dùng tốt trên bàn phím
JIS cùng bộ gõ tiếng Nhật của macOS. Giao diện theo `docs/DESIGN.md`. Nghiệp vụ: `docs/PRODUCT_SPEC.md`. Thứ tự công việc: `docs/PLAN.md`.
Prompt từng phase: `docs/prompts/phase-N.md`. Review: `docs/reviews/phase-N.md`.
Repo có sẵn (clone từ `maclifevn/mkey`): hiện trạng, baseline, quy ước — `docs/notes/codebase-map.md`.

## Quy tắc bắt buộc
1. Làm đúng phạm vi prompt của phase. Thấy cần làm thêm → ghi vào báo cáo PR, không tự làm.
2. Không push `main`. Mỗi phase một nhánh `phase-N-<tên>`, Conventional Commits (mô tả tiếng Việt), **mở PR** vào
   `main` của `origin` = `akachick113/vkey` (không bao giờ mở PR vào `upstream` = `maclifevn/mkey` hay `archive` =
   `akachick113/mkey-jis`) và gửi link.
3. Không sửa expectation của test cũ cho khớp output mới nếu không giải thích trong PR.
4. Mỗi ca test bắt buộc trong prompt là **một test riêng**, tên test nhắc tới số ca.
5. Không thêm / nâng dependency (Sparkle giữ `exactVersion` trong `project.yml`). Không commit `VKey.xcodeproj`.
6. Không commit khoá ký, khoá Sparkle (Ed25519), chứng chỉ, mật khẩu notarize. Không đổi `CODE_SIGN_IDENTITY`,
   `DEVELOPMENT_TEAM`, bundle id, `SUFeedURL`, `SUPublicEDKey` trừ khi prompt giao.
7. `Sources/Engine/` là engine OpenKey gốc: không sửa trừ khi prompt giao rõ. Logic JIS / phím tắt đặt ở
   `Sources/Platform/` (hoặc file mới ở đó), viết thành **hàm thuần** test được, không phụ thuộc event tap.
8. Hành vi trên bàn phím ANSI / ISO phải giữ nguyên: mọi test đặc tả ANSI của Phase 0 luôn xanh.
9. Callback event tap (`VKEngineCallback`) chạy trên mỗi phím: không thêm IPC / gọi TIS / truy vấn AX đồng bộ mới trên
   đường nóng; dùng cache, làm mới khi có notification (theo cách `VKUpdateInputSourceCache` đang làm).
10. Chuỗi giao diện tiếng Việt, theo giọng các chuỗi sẵn có. Khoá UserDefaults mới phải có trong "Cài đặt mặc định"
    (`AppState.resetToDefaults`) và danh sách đồng bộ iCloud nếu các khoá cùng loại đang có ở đó.
11. Mỗi thay đổi: chạy `scripts/check.sh`, đảm bảo pass trước khi kết thúc. Thay đổi ở event tap / UI phải chạy thử
    bản Debug thật trên máy (bàn phím JIS) và ghi kết quả theo kịch bản của prompt. Không chạy được (quyền Trợ năng,
    sandbox) → ghi vào mục "chưa kiểm được" của báo cáo.
12. Prompt, review, `PLAN.md` luôn đọc bản mới nhất trên `origin/main`: `git fetch origin` rồi
    `git show origin/main:docs/reviews/phase-N.md`. Không cần merge `main` vào nhánh phase để đọc.
13. Trên nhánh phase chỉ stage file mình sửa (`git add <file>`), không `git add -A` / `git add .`. Không commit
    `docs/prompts/`, `docs/reviews/`, `build/`.
14. Theo quy ước ở `docs/notes/codebase-map.md` §6. Không format lại / đổi tên / di chuyển file ngoài phạm vi. Không bump
    version trong `Info.plist` trừ khi prompt giao.
15. Không chạy song song hai bộ gõ: khi thử bản Debug, Input Method "MKey" (prototype IMK) không được là input source
    đang chọn.

## Lệnh
- `brew install xcodegen && xcodegen generate` — sinh project.
- `open VKey.xcodeproj` hoặc build Debug: `xcodebuild -project VKey.xcodeproj -scheme VKey -configuration Debug
  -derivedDataPath build/DerivedData build` → `build/DerivedData/Build/Products/Debug/VKey.app`
  (bundle id `io.github.akachick113.vkey.debug`, UserDefaults cùng domain).
- `scripts/check.sh` — build + toàn bộ test (Phase 0 tạo).

## Báo cáo
Trả lời bằng tiếng Việt theo mục "Khi xong" của prompt phase.
