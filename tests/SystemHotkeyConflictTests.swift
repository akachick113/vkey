import Foundation

@main
struct SystemHotkeyConflictTests {
    static func status(_ keyCode: UInt32, _ modifiers: UInt32 = 0, char: UInt32 = 0x20) -> Int32 {
        Int32(bitPattern: keyCode | modifiers | (char << 24))
    }

    static func case56_carbonModifiers() {
        for (carbon, expected): (Int, Int32) in [
            (0x100, 0x400), (0x200, 0x800), (0x800, 0x200), (0x1000, 0x100),
            (0x1800, 0x300), (0x21000, 0x100), (0x300, 0xC00), (0x400, 0)
        ] {
            precondition(SystemHotkeyConflict.modifiers(fromCarbon: carbon) == expected)
        }
    }

    static func case57_implicitFunctionKeys() {
        for key in [122, 120, 103, 111, 64, 90, 115, 117, 114, 123, 126] {
            precondition(SystemHotkeyConflict.carriesImplicitFunction(key))
        }
        for key in [0, 6, 12, 49, 102, 104, 93] {
            precondition(!SystemHotkeyConflict.carriesImplicitFunction(key))
        }
    }

    static func case58_matchingHotkeys() {
        precondition(SystemHotkeyConflict.matches(status: status(49, 0x400), SystemHotkey(keyCode: 49, carbonModifiers: 0x100)))
        precondition(SystemHotkeyConflict.matches(status: status(120, 0x100), SystemHotkey(keyCode: 120, carbonModifiers: 0x21000)))
        precondition(SystemHotkeyConflict.matches(status: status(103), SystemHotkey(keyCode: 103, carbonModifiers: 0x20000)))
        precondition(SystemHotkeyConflict.matches(status: status(123, 0x100), SystemHotkey(keyCode: 123, carbonModifiers: 0x21000)))
        precondition(SystemHotkeyConflict.matches(status: status(21, 0xC00 | 0x8000, char: 0x34), SystemHotkey(keyCode: 21, carbonModifiers: 0x300)))
    }

    static func case59_nonMatchingHotkeys() {
        precondition(!SystemHotkeyConflict.matches(status: status(49, 0x400), SystemHotkey(keyCode: 49, carbonModifiers: 0x1000)))
        precondition(!SystemHotkeyConflict.matches(status: 0x7A000206, SystemHotkey(keyCode: 6, carbonModifiers: 0x100)))
        precondition(!SystemHotkeyConflict.matches(status: status(12), SystemHotkey(keyCode: 12, carbonModifiers: 0x20000)))
        precondition(!SystemHotkeyConflict.matches(status: status(120, 0x100), SystemHotkey(keyCode: 120, carbonModifiers: 0x1000)))
        precondition(!SystemHotkeyConflict.matches(status: Int32(bitPattern: 0xFE0009FE), SystemHotkey(keyCode: 254, carbonModifiers: 0x1200)))
        for hotkey in [SystemHotkey(keyCode: 49, carbonModifiers: 0x1000),
                       SystemHotkey(keyCode: 6, carbonModifiers: 0x100),
                       SystemHotkey(keyCode: 12, carbonModifiers: 0x20000),
                       SystemHotkey(keyCode: 120, carbonModifiers: 0x1000),
                       SystemHotkey(keyCode: 254, carbonModifiers: 0x1200)] {
            precondition(!SystemHotkeyConflict.matches(status: Int32(bitPattern: 0xFE0000FE), hotkey))
        }
    }

    static func case60_defaultNames() {
        precondition(SystemHotkeyConflict.defaultName(status: status(49, 0x400)) == "Hiện tìm kiếm Spotlight")
        precondition(SystemHotkeyConflict.defaultName(status: status(49, 0x100 | 0x8000)) == "Chọn nguồn nhập trước đó")
        precondition(SystemHotkeyConflict.defaultName(status: status(120, 0x100)) == "Chuyển tới thanh menu")
        precondition(SystemHotkeyConflict.defaultName(status: 0x7A000206) == nil)
        precondition(SystemHotkeyConflict.defaultName(status: Int32(bitPattern: 0xFE0009FE)) == nil)
        precondition(SystemHotkeyConflict.defaultName(status: Int32(bitPattern: 0xFE0000FE)) == nil)
    }

    static func case61_warningMessages() {
        let advice = "Nên chọn tổ hợp khác, hoặc tắt phím tắt đó trong Cài đặt hệ thống → Bàn phím → Phím tắt bàn phím."
        precondition(SystemHotkeyConflict.warning(status: status(49, 0x400), enabledSystemHotkeys: [
            SystemHotkey(keyCode: 49, carbonModifiers: 0x100)
        ]) == "Trùng phím tắt đang bật của macOS (mặc định: “Hiện tìm kiếm Spotlight”). \(advice)")
        precondition(SystemHotkeyConflict.warning(status: status(40, 0x700), enabledSystemHotkeys: [
            SystemHotkey(keyCode: 40, carbonModifiers: 0x1900)
        ]) == "Trùng một phím tắt đang bật của macOS. \(advice)")
        precondition(SystemHotkeyConflict.warning(status: status(49, 0x400), enabledSystemHotkeys: []) == nil)
        let enabled = [SystemHotkey(keyCode: 49, carbonModifiers: 0x100),
                       SystemHotkey(keyCode: 49, carbonModifiers: 0x1000),
                       SystemHotkey(keyCode: 49, carbonModifiers: 0x1800),
                       SystemHotkey(keyCode: 49, carbonModifiers: 0x1100),
                       SystemHotkey(keyCode: 21, carbonModifiers: 0x300),
                       SystemHotkey(keyCode: 120, carbonModifiers: 0x21000),
                       SystemHotkey(keyCode: 123, carbonModifiers: 0x21000),
                       SystemHotkey(keyCode: 103, carbonModifiers: 0x20000),
                       SystemHotkey(keyCode: 48, carbonModifiers: 0x100),
                       SystemHotkey(keyCode: 102, carbonModifiers: 0),
                       SystemHotkey(keyCode: 104, carbonModifiers: 0)]
        precondition(SystemHotkeyConflict.warning(status: 0x7A000206, enabledSystemHotkeys: enabled) == nil)
        precondition(SystemHotkeyConflict.warning(status: status(102), enabledSystemHotkeys: enabled) == nil)
        precondition(SystemHotkeyConflict.warning(status: status(104), enabledSystemHotkeys: enabled) == nil)
    }

    static func main() {
        let tests = [case56_carbonModifiers, case57_implicitFunctionKeys, case58_matchingHotkeys,
                     case59_nonMatchingHotkeys, case60_defaultNames, case61_warningMessages]
        for test in tests { test() }
        print("PASS: \(tests.count) system hotkey conflict tests")
    }
}
