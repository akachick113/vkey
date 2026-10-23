# Phase 8a — Tên tác giả ở Giới thiệu, rút gọn ghi công, công tắc nhỏ hơn

> Codex · **GPT-6 Luna** · effort **Medium** (đổi chữ + một modifier, 4 file, mã ghi sẵn và Claude đã áp thử — WORKFLOW §8;
> Luna làm sai 1 lần → Sol · Medium, session mới) · nhánh `phase-8a-gioi-thieu-cong-tac` · **session Codex mới**

## Bối cảnh
Đọc `AGENTS.md`, `docs/PLAN.md` (**Phase 7** "✅ Phase 7 xong"; **Phase 8**), `docs/DESIGN.md` §"Giới thiệu" và dòng "Switch".
Repo `akachick113/vkey` (`origin`, public). VKey 1.0.1 đang phát hành. Người dùng chốt 2026-10-24 (sau khi xem bản 1.0.1):
1. Trang Giới thiệu ghi tên tác giả: **Trung Đức** (giữ `akachick113`).
2. Rút gọn đoạn ghi công dưới cùng như đã làm ở ghi chú phát hành (`docs/releases/1.0.1.md` chỉ còn "Phát hành theo giấy phép
   GPL v3."): bỏ câu "Dựa trên mã nguồn mở OpenKey … giấy phép GPL v3.", giữ 3 link — link **Ghi công** (→ `NOTICE.md`) và
   **Giấy phép GPL v3** vẫn là chỗ ghi công / giấy phép trong giao diện. `NOTICE.md`, README "Nguồn gốc & giấy phép", header
   © trong `Sources/Engine/` **giữ nguyên**.
3. Công tắc (switch) trong cửa sổ cài đặt hơi to → dùng cỡ `.small`.

Không đổi version (phát hành, nếu có, là 8b). Quy ước đã có, phải theo: `scripts/check.sh`; Conventional Commits tiếng Việt;
chỉ `git add <file>`; **không chạy formatter**, không ngắt lại dòng cũ. Không có ca test mới (ca mới vẫn đánh số từ **80**).

### Hiện trạng đã xem (Claude, `origin/main` @ `32d508f`, 2026-10-24)
- `Sources/App/Views/AboutPage.swift:72` `Text("Phát triển bởi **akachick113** · © 2026")`; `:77` câu "Dựa trên mã nguồn mở
  OpenKey (© Tuyen Mai) và mkey (© Anh Tuấn), giấy phép GPL v3." là dòng đầu của `VStack(spacing: 5)` chứa `HStack` 3 link.
- `Sources/Support/Info.plist:32` `NSHumanReadableCopyright` = `VKey © 2026 akachick113. Dựa trên OpenKey (© Tuyen Mai) và mkey
  (© Anh Tuấn), GPL v3.` (hiện ở Finder → Lấy thông tin).
- Công tắc kiểu `.switch` chỉ có **3 chỗ**: `VKComponents.swift:169` (`VKSwitchRow`), `TypingPage.swift:195` (`switchRow`),
  `TypingPage.swift:351` (`AXSupportAppRow`). Hai `Toggle` trong `VKeyApp.swift` là mục menu thanh menu — **không** đụng.
- Claude đo trên macOS 27.0.1: cỡ mặc định 54 × 24 pt, `.small` 44 × 20 pt, `.mini` 36 × 16 pt. Không test nào phụ thuộc các
  chuỗi trên. Claude đã áp thử đúng các thay đổi dưới trên worktree tạm → `numstat` như ở "Done khi".

## Việc 1 — Giới thiệu + bản quyền
Commit: `feat: ghi tên tác giả và rút gọn ghi công ở Giới thiệu`.
- `Sources/App/Views/AboutPage.swift`:
  - dòng 72 → `Text("Phát triển bởi **Trung Đức** (akachick113) · © 2026")`;
  - xoá cả dòng 77 (`Text("Dựa trên mã nguồn mở OpenKey …")`). Giữ nguyên `VStack(spacing: 5)`, `HStack` 3 link và mọi modifier.
- `Sources/Support/Info.plist`: chỉ thay chuỗi của `NSHumanReadableCopyright` thành
  `<string>VKey © 2026 Trung Đức (akachick113). GPL v3.</string>`. **Sửa dạng văn bản**, không ghi bằng `PlistBuddy` / `plutil`.

## Việc 2 — Công tắc cỡ nhỏ
Commit: `feat: thu nhỏ công tắc trong cửa sổ cài đặt`. Thêm `.controlSize(.small)` ngay sau `.toggleStyle(.switch)` ở đúng 3 chỗ:
- `VKComponents.swift:169` →
  `Toggle(title, isOn: $isOn).labelsHidden().toggleStyle(.switch).controlSize(.small).tint(VKTheme.accent)`
- `TypingPage.swift:195` →
  `Toggle(title, isOn: binding).labelsHidden().toggleStyle(.switch).controlSize(.small).tint(VKTheme.accent)` (dòng
  `.disabled(disabled)` bên dưới giữ nguyên)
- `TypingPage.swift:351-353`: thêm một dòng `                .controlSize(.small)` giữa `.toggleStyle(.switch)` và
  `.labelsHidden()`.

## Không được làm
- Không sửa file nào ngoài 4 file trên; không đụng `NOTICE.md`, README, `docs/`, `Sources/Engine/`, version trong `Info.plist`.
- Không đổi khoảng cách / chiều cao hàng (`VKRow`), không đổi `Toggle` trong menu thanh menu.
- Không mở bản Debug khi `/Applications/VKey.app` đang chạy; không thoát / thay `/Applications/VKey.app`. Phần chạy thật giao
  diện Claude làm khi review → ghi vào mục "chưa kiểm được".

## Done khi
- [ ] `scripts/check.sh` pass trên worktree sạch: `14 / 53 / 8 / 6 / 6 / 5`. CI xanh.
- [ ] `git diff --numstat origin/main` in **đúng** (thứ tự theo git):
      ```text
      1	2	Sources/App/Views/AboutPage.swift
      2	1	Sources/App/Views/TypingPage.swift
      1	1	Sources/App/Views/VKComponents.swift
      1	1	Sources/Support/Info.plist
      ```
- [ ] `grep -rn "Dựa trên" Sources/App Sources/Support` rỗng; `grep -rn "controlSize(.small)" Sources/App/Views` đúng 3 dòng.
- [ ] 2 commit như trên. Push nhánh `phase-8a-gioi-thieu-cong-tac`, **mở PR vào `main` của `origin`**, không Draft.

## Khi xong
Trả lời bằng tiếng Việt: tóm tắt, số test, CI, link PR, output `numstat` + 2 lệnh `grep`, chỗ khác prompt, chưa kiểm được (chạy
thật giao diện).
