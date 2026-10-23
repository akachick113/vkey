# Đóng góp cho VKey

Cảm ơn bạn đã quan tâm tới VKey! Mọi đóng góp đều được hoan nghênh — sửa lỗi,
thêm tính năng, cải thiện giao diện hay tài liệu.

## Quy trình

1. **Fork** repo này về tài khoản của bạn.
2. Tạo nhánh mới: `git checkout -b ten-tinh-nang`.
3. Commit thay đổi với mô tả rõ ràng (tiếng Việt hoặc tiếng Anh đều được).
4. Push lên fork của bạn và mở **Pull Request** vào nhánh `main`.

Nếu bạn muốn được cấp quyền commit trực tiếp (collaborator), hãy mở một issue
giới thiệu bản thân hoặc liên hệ chủ repo.

## Chuẩn bị môi trường

- macOS 14+ và Xcode 16+ (đã kiểm thử với Xcode 26 trên macOS 26).
- Cài [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`.

```bash
git clone https://github.com/akachick113/vkey.git
cd vkey
xcodegen generate
open VKey.xcodeproj
```

> File `VKey.xcodeproj` được sinh tự động từ `project.yml`, nên **không** commit
> nó. Khi thêm/bớt file nguồn, chỉ cần chạy lại `xcodegen generate`.

## Cấu trúc mã

| Thư mục | Nội dung |
|---|---|
| `Sources/Engine` | Engine gõ tiếng Việt C++ (kế thừa OpenKey, **không sửa trừ khi cần**) |
| `Sources/Platform` | Cầu nối ObjC++: `VKEngineHook.mm` (CGEventTap), `VKBridge` (facade cho Swift) |
| `Sources/App` | Giao diện SwiftUI: menu bar, cửa sổ cài đặt, `AppState` |
| `Sources/Support` | Info.plist, entitlements, bridging header, asset icon |
| `scripts/make_icon.swift` | Sinh app icon từ logo |

## Giấy phép

VKey dựa trên OpenKey và mkey (xem `NOTICE.md`) nên phát hành theo GPL v3.
Khi đóng góp, bạn đồng ý rằng phần đóng góp của mình cũng theo giấy phép này.
