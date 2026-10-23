import Foundation

enum HotkeyKeyName {
    /// Byte ký tự hiển thị lưu ở byte cao khi ghi phím tắt; nil = không ghi phím này.
    static func recordedCharacter(keyCode: UInt16, baseCharacters: String?) -> UInt8? {
        if keyCode == 49 { return 32 }
        guard keyCode < 0xFE else { return nil }
        if let name = keyName(keyCode: keyCode), name.hasPrefix("F") { return 0x10 }
        return baseCharacters?.utf8.first
    }

    static func isLanguageKey(_ keycode: UInt16) -> Bool {
        keycode == 102 || keycode == 104
    }

    /// Tên phím theo keycode; nil = hiển thị theo ký tự lưu ở byte cao.
    static func keyName(keyCode: UInt16) -> String? {
        switch keyCode {
        case 102: return "英数"
        case 104: return "かな"
        case 93: return "¥"
        case 94: return "_"
        case 122: return "F1"
        case 120: return "F2"
        case 99: return "F3"
        case 118: return "F4"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        case 105: return "F13"
        case 107: return "F14"
        case 113: return "F15"
        case 106: return "F16"
        case 64: return "F17"
        case 79: return "F18"
        case 80: return "F19"
        case 90: return "F20"
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        default: return nil
        }
    }

    static func name(status: Int32) -> String? {
        let value = UInt32(bitPattern: status)
        if let name = keyName(keyCode: UInt16(value & 0xFF)) { return name }
        let char = UInt8((value >> 24) & 0xFF)
        guard char != 0xFE else { return nil }
        if char == 49 || Character(UnicodeScalar(char)) == " " { return "Space" }
        return String(UnicodeScalar(char)).uppercased()
    }

    static func usesLanguageKey(status: Int32) -> Bool {
        let value = UInt32(bitPattern: status)
        return (value & ~0x8000) != 0xFE0000FE && isLanguageKey(UInt16(value & 0xFF))
    }
}
