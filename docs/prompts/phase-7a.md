# Phase 7a — Ẩn nút "Lịch sử phiên bản" của Sparkle

> Codex · **GPT-6 Luna** · effort **High** (2 file, đoạn mã ghi sẵn và Claude đã chạy thử; giống 6a — WORKFLOW §8; Luna làm
> sai 1 lần → chuyển Sol · Medium, session mới) · nhánh `phase-7a-hide-version-history` · **session Codex mới**

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 6**: "✅ Phase 6 xong" + Còn tồn; **Phase 7**), `docs/UPDATES.md` mục "Kiểm thử".
Repo là `akachick113/vkey` (`origin`, public). VKey 1.0.0 đã phát hành. Khi người dùng chọn "Kiểm tra cập nhật…" và đang ở
bản mới nhất, Sparkle hiện hộp thoại có nút **Lịch sử phiên bản**; nút này mở `VKey-1.0.0.md` thô trên GitHub (trình duyệt tải
file về). Người dùng chốt: **ẩn** nút này. Không đổi version (phát hành 1.0.1 là 7b, sau).

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; Conventional Commits tiếng Việt; chỉ `git add <file>`; **không chạy
formatter**, thụt 4 dấu cách theo dòng xung quanh, không ngắt lại dòng cũ. Ca test mới: **79**.

### Hiện trạng đã xem (Claude, `origin/main` @ `5693b3b`, 2026-10-24)
- `Sources/App/UpdateChecker.swift`: lớp `@MainActor final class UpdateChecker: NSObject, ObservableObject, SPUUpdaterDelegate`
  (dòng 8); `SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: self, userDriverDelegate: nil)` (dòng 26–28).
  Hàm `updater(_:didFindValidUpdate:)` ở ~dòng 133.
- Sparkle 2.9.6, `SPUStandardUserDriverDelegate.h:64`: `- (BOOL)standardUserDriverShouldShowVersionHistoryForAppcastItem:` —
  trả `NO` thì không có nút "Version History" ("Lịch sử phiên bản") trong hộp thoại "không có bản mới".
- `tests/UpdateControllerSmoke.swift`: app chủ dùng `UpdateChecker` thật; timer 0,2 s gọi `NSApp.abortModal()` khi có hộp thoại
  modal; `finish(_:)` ghi `PASS:` / `FAIL:` ra file. `tests/run-update-smoke.py FEED` biên dịch smoke với
  `build/DerivedData/Build/Products/Release` của repo, chạy 4 kịch bản (`upToDate`, `available`, `failed` × 2) trong app tạm ở
  `/Applications`, tự dọn. Smoke **không** nằm trong `check.sh` (cần Release build + feed đã ký).
- Claude đã áp thử đúng các thay đổi dưới vào worktree tạm: trước khi sửa, hộp thoại `upToDate` có nút
  `OK | Lịch sử phiên bản`; sau khi sửa chỉ còn `OK`; ca 79 pass 3/3 lần và **FAIL** đúng (`version history button shown`) khi
  bỏ delegate; đủ 4 kịch bản smoke pass; Debug build không cảnh báo. Bỏ `nonisolated` → cảnh báo `ConformanceIsolation`.
- Máy người dùng: `/Applications/VKey.app` 1.0.0 đang chạy là bộ gõ hằng ngày. Không có bản Debug nào cài.

## Việc 1 — Ẩn nút (`Sources/App/UpdateChecker.swift`)
Commit: `fix: ẩn nút Lịch sử phiên bản của Sparkle`. Đúng 3 chỗ, không đổi gì khác:
1. Dòng khai báo lớp thêm `, SPUStandardUserDriverDelegate` vào cuối danh sách:
   `final class UpdateChecker: NSObject, ObservableObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {`
2. `userDriverDelegate: nil` → `userDriverDelegate: self`.
3. Ngay **trước** `func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {`, thêm (kèm một dòng trống sau):
   ```swift
       // Release notes are a raw Markdown asset; browsers download it instead of showing it.
       nonisolated func standardUserDriverShouldShowVersionHistory(for item: SUAppcastItem) -> Bool {
           false
       }

   ```

## Việc 2 — Ca test 79 (`tests/UpdateControllerSmoke.swift`)
Commit: `test: ca 79 hộp thoại đã mới nhất không có Lịch sử phiên bản`. Đúng 4 chỗ:
1. Sau `private var alertTimer: Timer?` thêm: `    private var alertButtons: [[String]] = []`
2. Thay dòng `                if NSApp.modalWindow != nil { NSApp.abortModal() }` bằng:
   ```swift
                   if let window = NSApp.modalWindow {
                       self.alertButtons.append(Self.buttonTitles(in: window.contentView))
                       NSApp.abortModal()
                   }
   ```
3. Ngay **trước** `    private func finish(_ result: String) {` thêm:
   ```swift
       private static func buttonTitles(in view: NSView?) -> [String] {
           guard let view else { return [] }
           return ((view as? NSButton).map { [$0.title] } ?? []) + view.subviews.flatMap { buttonTitles(in: $0) }
       }

   ```
4. Ngay **sau** dòng `    private func finish(_ result: String) {` thêm:
   ```swift
           var result = result
           // Case 79: the "up to date" alert must not offer Sparkle's version history.
           if result == "upToDate" {
               if alertButtons.isEmpty {
                   result = "FAIL: no up-to-date alert"
               } else if alertButtons.joined().contains(where: { ["Lịch sử phiên bản", "Version History"].contains($0) }) {
                   result = "FAIL: version history button shown"
               }
           }
   ```
`tests/run-update-smoke.py` **không** sửa.

## Không được làm
- Không đổi version / build, `Info.plist`, `project.yml`, `docs/releases/`, script phát hành, feed. Không tag, không Release.
- Không sửa file nào ngoài 2 file trên. Không thêm dependency. Không push `main`. Không chạy formatter.
- **Không mở** bản Debug hay Release vừa build (hai VKey cùng lúc xử lý phím hai lần); không thoát `/Applications/VKey.app`.
- Không sửa expectation của 3 kịch bản smoke còn lại.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `14 / 53 / 8 / 6 / 6 / 5` (không đổi). CI xanh trên PR.
- [ ] Lệnh sau in **đúng** bảng dưới:
      `bash -c 'git diff --numstat origin/main -- Sources tests | while read a d f; do echo "$a $d | -w $(git diff -w --numstat origin/main -- $f | cut -f1,2 | tr "\t" " ") | $f"; done'`
      ```text
      7 2 | -w 7 2 | Sources/App/UpdateChecker.swift
      19 1 | -w 19 1 | tests/UpdateControllerSmoke.swift
      ```
- [ ] Smoke với feed 1.0.0 thật (từ thư mục gốc repo, nhánh của bạn):
      ```bash
      xcodebuild -project VKey.xcodeproj -scheme VKey -configuration Release -derivedDataPath build/DerivedData build
      curl -fsSL -o build/appcast-1.0.0.xml https://github.com/akachick113/vkey/releases/latest/download/appcast.xml
      python3 tests/run-update-smoke.py build/appcast-1.0.0.xml
      ```
      → 4 dòng `PASS:` (`upToDate`, `available`, `failed`, `failed`). Rồi tạm hoàn tác Việc 1
      (`git stash push Sources/App/UpdateChecker.swift`), chạy lại → dòng `valid.xml` đầu tiên là
      `FAIL: expected upToDate, got FAIL: version history button shown`; `git stash pop`. Dán cả hai output.
      Sau đó gỡ đăng ký bản build khỏi danh sách app của macOS (người dùng không muốn thấy nhiều VKey):
      `/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u build/DerivedData/Build/Products/Release/VKey.app`
      (và `…/Debug/VKey.app` nếu có).
- [ ] PR đã mở vào `main` của `origin` (`akachick113/vkey`), không Draft.

## Khi xong
Hai commit như trên. Push nhánh `phase-7a-hide-version-history`, **mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt và
**ghi toàn văn báo cáo vào `build/phase-7a-report.md`** (không commit), gồm:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả lệnh `numstat`, hai lần chạy smoke.
3. Chỗ khác prompt và lý do; chỗ chưa chắc.
