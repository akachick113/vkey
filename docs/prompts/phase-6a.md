# Phase 6a — Dọn còn tồn 5d + chuẩn bị VKey 1.0.0

> Codex · **GPT-6 Luna** · effort **High** (việc nhỏ, đã ghi sẵn từng đoạn code / nội dung; nhiều file nên High — WORKFLOW
> §8; Luna làm sai 1 lần → chuyển Sol · Medium, session mới) · nhánh `phase-6a-release-prep` · **session Codex mới**

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 5**: "✅ 5d xong" — Quyết định đã chốt + Còn tồn; **Phase 6**). Phase 6 chuyển
sang repo mới `akachick113/vkey` và phát hành bản đầu **1.0.0 (build 2)**. Phase 6a chỉ chuẩn bị mã + tài liệu trong repo
hiện tại; PR vẫn mở vào `main` của `origin` (`akachick113/mkey-jis`) như mọi phase trước. Việc chuyển repo (6b) và phát
hành (6c) **không** thuộc phase này.

Quy ước đã có, phải theo: `scripts/check.sh` là CHECK_CMD; Conventional Commits tiếng Việt; chỉ `git add <file>`; **không
chạy `swift-format` / `swiftformat` / formatter nào**, thụt 4 dấu cách theo dòng xung quanh, không ngắt lại dòng cũ. Không có
ca test mới (ca mới vẫn đánh số từ **79**).

### Hiện trạng đã xem (Claude, `origin/main` @ `abab86b`, 2026-10-24)
- `Sources/App/VKeyApp.swift` ~dòng 114–121: submenu `Bàn phím` là `Menu("Bàn phím") { Picker("Bàn phím", …) { … }
  .pickerStyle(.inline).labelsHidden() }`. Đọc qua Accessibility, submenu có 2 mục phân cách rỗng (đầu, cuối) quanh 3 lựa
  chọn. Ngay trên, `Kiểu gõ` và `Bảng mã` là `Picker` thẳng (SwiftUI tự thành submenu, không có phân cách thừa).
- `Sources/App/Views/SystemPage.swift`, thẻ `CẬP NHẬT`: 2 `Text` (`Kiểm tra lần cuối: …` và `notice`) có
  `.padding(.vertical, 11).padding(.horizontal, 16)` nhưng không có `frame` → hiện căn giữa thẻ.
- `Sources/App/Views/ConvertPage.swift`: 3 popup (`Từ bảng mã`, `Sang bảng mã`, `Chuyển đổi`) đều
  `.labelsHidden().pickerStyle(.menu).frame(width: 215)`. Popup kiểu menu chỉ rộng bằng mục dài nhất của nó, nên popup
  `Chuyển đổi` (≈171 pt) nằm giữa khung 215 → lệch khỏi mép phải so với 2 popup bảng mã.
- `Sources/App/Views/MacroPage.swift`, thẻ `THÊM / SỬA GÕ TẮT`: 2 `TextField` có `.labelsHidden()` → Accessibility không có
  nhãn (VoiceOver không đọc tên ô).
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` = `1.7.0`, `CFBundleVersion` = `14`. Chưa có thư mục
  `docs/releases/` (bản `1.7.0.md` của MKey JIS đã xoá ở 5a). `scripts/prepare-local-update-test.sh` đòi build ≥ 2;
  `tests/run-update-smoke.py` dùng build − 1 → build 2 dùng được.
- `README.md` mục `## Tính năng` chưa nhắc chọn bàn phím Tự động / JIS / Tiếng Anh (có từ 5c).

## Việc 0 — Còn tồn 5d (C1–C4)
Sửa đúng các đoạn dưới; không đổi gì khác trong các file này. Commit: `fix: dọn còn tồn giao diện 5d`.

**C1** — `VKeyApp.swift`, thay cả khối `Menu("Bàn phím") { … }` bằng:
```swift
            Picker("Bàn phím", selection: $state.keyboardMode) {
                Text("Tự động").tag(0)
                Text("JIS (Nhật)").tag(1)
                Text("Tiếng Anh (US)").tag(2)
            }
```
(thụt lề bằng `Picker("Bảng mã", …)` ngay trên nó).

**C2** — `SystemPage.swift`, thêm một dòng `.frame(maxWidth: .infinity, alignment: .leading)` **ngay trước**
`.padding(.vertical, 11).padding(.horizontal, 16)` của 2 `Text` này (không đụng chỗ khác):
```swift
                    Text("Kiểm tra lần cuối: \(lastCheck.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundStyle(VKTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 11).padding(.horizontal, 16)
```
```swift
                    Text(notice)
                        .font(.footnote)
                        .foregroundStyle(VKTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 11).padding(.horizontal, 16)
```

**C3** — `ConvertPage.swift`, ở **cả 3** popup đổi `.frame(width: 215)` thành `.frame(width: 215, alignment: .trailing)`.

**C4** — `MacroPage.swift`, thêm sau `.labelsHidden()` của từng ô:
- ô `TextField("Từ tắt", …)`: `.accessibilityLabel("Từ tắt")`
- ô `TextField("Nội dung thay thế", …)`: `.accessibilityLabel("Nội dung thay thế")`

## Việc 1 — Version 1.0.0 (build 2) + ghi chú phát hành
Commit: `chore: chuẩn bị phát hành VKey 1.0.0`.
- `Sources/Support/Info.plist`: `CFBundleShortVersionString` → `1.0.0`, `CFBundleVersion` → `2`. Không đổi khoá nào khác.
- Tạo `docs/releases/1.0.0.md` với **đúng** nội dung sau (giữa hai dòng `---8<---`, không chép hai dòng đó):

---8<---
# VKey 1.0.0

Bản đầu tiên của **VKey** — bộ gõ tiếng Việt cho macOS, dùng tốt trên bàn phím JIS cùng bộ gõ tiếng Nhật của macOS.
Dựa trên mã nguồn mở OpenKey và mkey (giấy phép GPL v3, xem `NOTICE.md`).

## Tính năng

- Gõ Telex / VNI, 5 bảng mã, tuỳ chọn chính tả, gõ tắt (đồng bộ iCloud Drive), lịch sử clipboard, chuyển mã nhanh.
- Bàn phím JIS: gõ đúng ký tự; かな sang tiếng Nhật, 英数 về Latin / đổi Việt ⇄ Anh theo tuỳ chọn.
- Chọn bàn phím **Tự động / JIS (Nhật) / Tiếng Anh (US)** ở trang Bộ gõ và menu thanh menu.
- Giao diện mới song ngữ Việt–Nhật, sáng / tối; icon thanh menu VI / EN / あ.
- Tự kiểm tra và cài bản cập nhật (Sparkle, có xác thực chữ ký).

## Cài đặt

1. Thoát các bộ gõ tiếng Việt khác đang chạy.
2. Giải nén **VKey-1.0.0.zip**, kéo `VKey.app` vào **/Applications**.
3. App **chưa notarize**: lần mở đầu vào Cài đặt hệ thống → Quyền riêng tư & Bảo mật → **Vẫn mở**; hoặc chạy
   `xattr -dr com.apple.quarantine /Applications/VKey.app`.
4. Cấp quyền **Trợ năng** cho **VKey** trong Cài đặt hệ thống → Quyền riêng tư & Bảo mật → Trợ năng. App tự nhận quyền,
   không cần mở lại.

Hỗ trợ **Apple Silicon và Intel**, yêu cầu **macOS 14 trở lên**.
---8<---

- `README.md`, mục `## Tính năng`: thêm **một** gạch đầu dòng ngay sau dòng `- Gõ đúng ký tự trên bàn phím JIS, kể cả khi
  bật tương thích bố cục.`:
  `- Chọn bàn phím Tự động / JIS (Nhật) / Tiếng Anh (US) ở trang Bộ gõ và menu thanh menu; cảnh báo khi chế độ không khớp
  bàn phím đang gõ.`
  Không sửa chỗ nào khác của README.

## Không được làm
- Không làm 6b / 6c: không đổi remote, không tạo repo, không tag, không build Release, không ký, không dựng feed.
- Không đổi `SUFeedURL`, `SUPublicEDKey`, bundle id, ký, `project.yml`, `.github/`, `Sources/Engine/`, `Sources/Platform/`,
  `VKTheme`, `VKComponents`, các trang ngoài 4 file ở Việc 0. Không thêm dependency. Không sửa `AGENTS.md`, `CLAUDE.md`,
  `docs/` ngoài `docs/releases/1.0.0.md`. Không push `main`.
- Không chạy formatter; không đổi khoảng trắng / ngắt dòng ở dòng không thuộc việc.

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `14 / 53 / 8 / 6 / 6 / 5` (policy / engine / hotkey name / hotkey conflict /
      release signature / keyboard mode). CI xanh.
- [ ] Không có thay đổi ngoài việc — lệnh sau phải in **đúng** bảng dưới (Claude đã áp thử các thay đổi trên và đo; dán kết
      quả vào báo cáo). `VKeyApp.swift` có `-w` khác vì khối `Picker` bớt một mức thụt lề — đúng dự kiến.
      `bash -c 'git diff --numstat origin/main -- Sources README.md | while read a d f; do echo "$a $d | -w $(git diff -w --numstat origin/main -- $f | cut -f1,2 | tr "\t" " ") | $f"; done'`
      ```text
      2 0 | -w 2 0 | README.md
      4 7 | -w 0 3 | Sources/App/VKeyApp.swift
      3 3 | -w 3 3 | Sources/App/Views/ConvertPage.swift
      2 0 | -w 2 0 | Sources/App/Views/MacroPage.swift
      2 0 | -w 2 0 | Sources/App/Views/SystemPage.swift
      2 2 | -w 2 2 | Sources/Support/Info.plist
      ```
      Lệch → xem lại việc tương ứng, không sửa thêm để "cho khớp".
- [ ] `/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' -c 'Print :CFBundleVersion' Sources/Support/Info.plist`
      → `1.0.0` / `2`; `docs/releases/1.0.0.md` khớp từng ký tự nội dung trên (`diff` với bản chép từ prompt → rỗng).
- [ ] Không chạy thật / chụp ảnh: Claude tự kiểm submenu `Bàn phím`, căn lề, nhãn Accessibility khi review.
- [ ] PR đã mở vào `main` của `origin` (không Draft).

## Khi xong
Hai commit như trên. Push nhánh `phase-6a-release-prep`, **mở PR vào `main`** và gửi link. Trả lời bằng tiếng Việt và
**ghi toàn văn báo cáo vào `build/phase-6a-report.md`** (không commit), gồm:
1. Tóm tắt; số test; CI; link PR.
2. Kết quả lệnh `numstat` và lệnh `PlistBuddy`.
3. Chỗ khác prompt và lý do; chỗ chưa chắc.
