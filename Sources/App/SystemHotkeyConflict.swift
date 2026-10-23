import Foundation

struct SystemHotkey: Equatable {
    let keyCode: Int
    let carbonModifiers: Int
}

enum SystemHotkeyConflict {
    static func modifiers(fromCarbon carbon: Int) -> Int32 {
        var result: Int32 = 0
        if carbon & 0x100 != 0 { result |= 0x400 } // cmdKey → ⌘
        if carbon & 0x200 != 0 { result |= 0x800 } // shiftKey → ⇧
        if carbon & 0x800 != 0 { result |= 0x200 } // optionKey → ⌥
        if carbon & 0x1000 != 0 { result |= 0x100 } // controlKey → ⌃
        return result
    }

    /// macOS tự gắn cờ fn cho các phím chức năng và điều hướng này.
    static func carriesImplicitFunction(_ keyCode: Int) -> Bool {
        switch keyCode {
        case 122, 120, 99, 118, 96, 97, 98, 100, 101, 109, // F1–F10
             103, 111, 105, 107, 113, 106, 64, 79, 80, 90, // F11–F20
             115, 119, 116, 121, 117, 114, 123, 124, 125, 126:
            return true
        default: return false
        }
    }

    private static func hasKey(_ status: Int32) -> Bool {
        let value = UInt32(bitPattern: status)
        return (value & ~0x8000) != 0xFE0000FE && value & 0xFF != 0xFE
    }

    static func matches(status: Int32, _ hotkey: SystemHotkey) -> Bool {
        hasKey(status) && Int(status & 0xFF) == hotkey.keyCode
            && status & 0xF00 == modifiers(fromCarbon: hotkey.carbonModifiers)
            && (hotkey.carbonModifiers & 0x20000 != 0) == carriesImplicitFunction(hotkey.keyCode) // fn
    }

    /// Tên mặc định của tổ hợp, không suy đoán chức năng người dùng đã gán lại.
    static func defaultName(status: Int32) -> String? {
        guard hasKey(status) else { return nil }
        switch (status & 0xFF, status & 0xF00) {
        case (49, 0x400): return "Hiện tìm kiếm Spotlight"
        case (49, 0x600): return "Hiện cửa sổ tìm kiếm của Finder"
        case (49, 0x100): return "Chọn nguồn nhập trước đó"
        case (49, 0x300): return "Chọn nguồn tiếp theo trong menu Nhập"
        case (49, 0x500): return "Biểu tượng & ký hiệu"
        case (48, 0x400): return "Chuyển ứng dụng"
        case (48, 0xC00): return "Chuyển ứng dụng (ngược)"
        case (53, 0x600): return "Buộc thoát ứng dụng"
        case (50, 0x400): return "Chuyển tới cửa sổ tiếp theo"
        case (20, 0xC00): return "Lưu ảnh màn hình thành tệp"
        case (20, 0xD00): return "Chép ảnh màn hình vào clipboard"
        case (21, 0xC00): return "Lưu ảnh vùng chọn thành tệp"
        case (21, 0xD00): return "Chép ảnh vùng chọn vào clipboard"
        case (23, 0xC00): return "Tuỳ chọn chụp màn hình"
        case (2, 0x600): return "Bật / tắt tự ẩn Dock"
        case (44, 0xC00): return "Hiện menu Trợ giúp"
        case (126, 0x100): return "Mission Control"
        case (125, 0x100): return "Cửa sổ của ứng dụng"
        case (123, 0x100): return "Sang trái một Space"
        case (124, 0x100): return "Sang phải một Space"
        case (103, 0): return "Hiện màn hình nền"
        case (122, 0x100): return "Bật / tắt truy cập bàn phím"
        case (120, 0x100): return "Chuyển tới thanh menu"
        case (99, 0x100): return "Chuyển tới Dock"
        case (118, 0x100): return "Chuyển tới cửa sổ đang dùng hoặc cửa sổ kế tiếp"
        case (96, 0x100): return "Chuyển tới thanh công cụ của cửa sổ"
        case (97, 0x100): return "Chuyển tới cửa sổ nổi"
        case (98, 0x100): return "Đổi cách Tab di chuyển tiêu điểm"
        case (100, 0x100): return "Chuyển tới menu trạng thái"
        case (96, 0x400): return "Bật / tắt VoiceOver"
        case (96, 0x600): return "Hiện bảng điều khiển Trợ năng"
        default: return nil
        }
    }

    static func warning(status: Int32, enabledSystemHotkeys: [SystemHotkey]) -> String? {
        let keyCode = status & 0xFF
        guard keyCode != 102, keyCode != 104,
              enabledSystemHotkeys.contains(where: { matches(status: status, $0) }) else { return nil }
        let advice = "Nên chọn tổ hợp khác, hoặc tắt phím tắt đó trong Cài đặt hệ thống → Bàn phím → Phím tắt bàn phím."
        if let name = defaultName(status: status) {
            return "Trùng phím tắt đang bật của macOS (mặc định: “\(name)”). \(advice)"
        }
        return "Trùng một phím tắt đang bật của macOS. \(advice)"
    }
}
