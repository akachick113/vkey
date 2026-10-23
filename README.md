# VKey — Bộ gõ tiếng Việt cho macOS

**VKey** hỗ trợ gõ Telex / VNI, chạy tốt trên bàn phím JIS cùng bộ gõ tiếng Nhật
của macOS. Giao diện SwiftUI tối ưu cho macOS 26, yêu cầu tối thiểu macOS 14.

## Tính năng

- Gõ Telex / VNI, 5 bảng mã, tuỳ chọn chính tả và chuyển mã nhanh.
- Gõ đúng ký tự trên bàn phím JIS, kể cả khi bật tương thích bố cục.
- Chọn bàn phím Tự động / JIS (Nhật) / Tiếng Anh (US) ở trang Bộ gõ và menu thanh menu; cảnh báo khi chế độ không khớp
  bàn phím đang gõ.
- かな sang tiếng Nhật; 英数 về Latin / đổi Việt ⇄ Anh theo tuỳ chọn.
  Hai phím luôn kết thúc từ đang gõ.
- Phím tắt tuỳ chỉnh, cảnh báo khi trùng phím tắt đang bật của macOS.
- Gõ tắt, đồng bộ qua iCloud Drive, lịch sử clipboard có hỗ trợ ảnh.
- Loại trừ ứng dụng, nhớ chế độ gõ và bảng mã theo từng ứng dụng.
- Cửa sổ cài đặt SwiftUI với sidebar, hỗ trợ Dark Mode; icon VI/EN tự đổi màu
  theo menu bar sáng/tối.
- Cập nhật trong ứng dụng bằng Sparkle: tự kiểm tra, tải bản mới, xác thực chữ ký,
  cài đặt và mở lại VKey; tuỳ chọn tự tải/cài khi thoát.
- Khởi động cùng macOS qua SMAppService.
- Event tap tự hồi phục khi bị hệ thống tắt; tự phát hiện quyền Trợ năng được cấp
  mà không cần khởi động lại ứng dụng.

## Cấu trúc

```
VKey/
├── project.yml              # đặc tả XcodeGen
├── scripts/make_icon.swift  # sinh app icon bằng CoreGraphics
└── Sources/
    ├── Engine/              # engine C++
    ├── Platform/            # glue ObjC++: event tap, bridge engine ↔ Swift
    │   ├── VKGlobals.h      # khai báo biến cấu hình cho Swift
    │   ├── VKBridge.h/.mm   # facade: tap lifecycle, macro, chuyển mã
    │   ├── VKKeyLayout.h/.cpp # ánh xạ bàn phím JIS
    │   └── VKEngineHook.mm  # CGEventTap callback + key synthesis
    ├── App/                 # SwiftUI: VKeyApp, Settings, AppState
    └── Support/             # Info.plist, VKey.entitlements, VKey-Bridging-Header.h, assets
```

## Build

Yêu cầu: macOS 14+, Xcode 16+ (đã kiểm thử với Xcode 26.5 trên macOS 26.5),
[XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
cd vkey
swift scripts/make_icon.swift Sources/Support/Assets.xcassets/AppIcon.appiconset  # nếu muốn sinh lại icon
xcodegen generate
xcodebuild -project VKey.xcodeproj -scheme VKey -configuration Release -derivedDataPath build
open build/Build/Products/Release/   # chứa VKey.app
```

Release ký bằng chứng chỉ Apple Development của chủ dự án, team `8C4YAMZSGP`.
Người khác tự build có thể dùng Debug (`scripts/check.sh`) hoặc thêm
`CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=` vào lệnh `xcodebuild` ở trên.
Debug có bundle id riêng `io.github.akachick113.vkey.debug` và tên **VKey Debug**.

## Cài đặt & cấp quyền

1. **Thoát các bộ gõ tiếng Việt khác đang chạy** (hai bộ gõ event tap cùng lúc sẽ
   xử lý mỗi phím hai lần).
2. Tải `VKey-<version>.zip` ở [GitHub Releases](https://github.com/akachick113/vkey/releases),
   giải nén, kéo `VKey.app` vào **Applications**. Cập nhật tự động chỉ chạy khi
   app nằm trực tiếp trong `/Applications`.
3. App **chưa notarize**, nên lần mở đầu macOS có thể chặn: Cài đặt hệ thống →
   Quyền riêng tư & Bảo mật → **Vẫn mở**; hoặc chạy
   `xattr -dr com.apple.quarantine /Applications/VKey.app`.
4. Cấp quyền **Trợ năng (Accessibility)**: Cài đặt hệ thống → Quyền riêng tư & Bảo mật →
   Trợ năng → bật **VKey** (tên file app). App tự phát hiện quyền và bắt đầu hoạt động,
   không cần mở lại.
5. Bật **Japanese – Romaji** trong Nguồn nhập.
   **⌥Z** chuyển Việt/Anh; tuỳ chọn 英数 / かな ở Bảng điều khiển → Bộ gõ.

> **Chữ ký ứng dụng**: Debug ký ad-hoc và có bundle id riêng; Release ký Apple
> Development team `8C4YAMZSGP` của chủ dự án, không có Developer ID và chưa notarize.
> Khi thay đổi định danh ký, macOS có thể yêu cầu cấp lại quyền Trợ năng.

## Auto update và phát hành

Xem [hướng dẫn cập nhật](docs/UPDATES.md) để tạo gói và feed Sparkle đã ký,
kiểm thử và phát hành.

## Nguồn gốc & giấy phép

VKey là bản sửa đổi dựa trên engine [OpenKey](https://github.com/tuyenvm/OpenKey)
(© Tuyen Mai) và giao diện, bridge của [mkey](https://github.com/maclifevn/mkey)
(© Anh Tuấn). Dự án phát hành theo [GPL-3.0](LICENSE); chi tiết ghi công và các
thay đổi tại [NOTICE.md](NOTICE.md).
