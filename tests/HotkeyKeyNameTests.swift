import Foundation

@main
struct HotkeyKeyNameTests {
    static func status(_ keycode: UInt32, _ modifiers: UInt32 = 0, char: UInt32 = 0x20) -> Int32 {
        Int32(bitPattern: keycode | modifiers | (char << 24))
    }

    static func case48_languageKeyNames() {
        precondition(HotkeyKeyName.name(status: status(102, 0x100)) == "英数")
        precondition(HotkeyKeyName.name(status: status(104)) == "かな")
    }

    static func case49_jisPunctuationNames() {
        precondition(HotkeyKeyName.name(status: status(93, char: 0xC2)) == "¥")
        precondition(HotkeyKeyName.name(status: status(93, 0x800, char: 0x7C)) == "¥")
        precondition(HotkeyKeyName.name(status: status(94, char: 0x5F)) == "_")
    }

    static func case50_existingKeyNames() {
        precondition(HotkeyKeyName.name(status: 0x7A000206) == "Z")
        precondition(HotkeyKeyName.name(status: status(49, 0x100)) == "Space")
        precondition(HotkeyKeyName.name(status: status(30, 0x900, char: 0x5B)) == "[")
        precondition(HotkeyKeyName.name(status: Int32(bitPattern: 0xFE0009FE)) == nil)
        precondition(HotkeyKeyName.name(status: Int32(bitPattern: 0xFE0000FE)) == nil)
    }

    static func case51_savedLanguageKeyDetection() {
        precondition(HotkeyKeyName.usesLanguageKey(status: status(102, 0x100 | 0x8000)))
        precondition(HotkeyKeyName.usesLanguageKey(status: status(104)))
        precondition(!HotkeyKeyName.usesLanguageKey(status: 0x7A000206))
        precondition(!HotkeyKeyName.usesLanguageKey(status: Int32(bitPattern: 0xFE0000FE | 0x8000)))
        precondition(!HotkeyKeyName.usesLanguageKey(status: status(93, char: 0xC2)))
    }

    static func case55_recordedBaseCharacter() {
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 6, baseCharacters: "z") == 0x7A)
        let recorded = status(6, 0x200, char: 0x7A)
        precondition(recorded == 0x7A000206)
        precondition(HotkeyKeyName.name(status: recorded) == "Z")
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 49, baseCharacters: nil) == 32)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 30, baseCharacters: "[") == 0x5B)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 93, baseCharacters: "¥") == 0xC2)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 6, baseCharacters: nil) == nil)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 6, baseCharacters: "") == nil)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 0xFE, baseCharacters: "a") == nil)
    }

    static func case62_functionKeyNames() {
        let keycodes: [UInt32] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109,
                                 103, 111, 105, 107, 113, 106, 64, 79, 80, 90]
        for (index, keycode) in keycodes.enumerated() {
            let expected = "F\(index + 1)"
            precondition(HotkeyKeyName.name(status: status(keycode, 0x100, char: 0x10)) == expected)
            precondition(HotkeyKeyName.name(status: status(keycode, char: 0x00)) == expected)
            precondition(HotkeyKeyName.name(status: status(keycode, 0x100 | 0x8000, char: 0xEF)) == expected)
        }
        precondition(HotkeyKeyName.name(status: 0x10000178) == "F2")
    }

    static func case63_arrowKeyNames() {
        let arrows: [(UInt32, UInt32, String)] = [
            (123, 0x1C, "←"), (124, 0x1D, "→"), (125, 0x1F, "↓"), (126, 0x1E, "↑")
        ]
        for (keycode, character, expected) in arrows {
            precondition(HotkeyKeyName.name(status: status(keycode, 0x100, char: character)) == expected)
            precondition(HotkeyKeyName.name(status: status(keycode, char: 0x20)) == expected)
        }
    }

    static func case64_recordedFunctionAndArrowCharacter() {
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 120, baseCharacters: "\u{10}") == 0x10)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 64, baseCharacters: "") == 0x10)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 90, baseCharacters: nil) == 0x10)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 122, baseCharacters: "x") == 0x10)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 123, baseCharacters: "\u{1C}") == 0x1C)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 126, baseCharacters: "\u{1E}") == 0x1E)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 6, baseCharacters: "z") == 0x7A)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 0, baseCharacters: "") == nil)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 0xFE, baseCharacters: "a") == nil)
        precondition(HotkeyKeyName.recordedCharacter(keyCode: 49, baseCharacters: nil) == 32)
    }

    static func main() {
        let tests = [case48_languageKeyNames, case49_jisPunctuationNames,
                     case50_existingKeyNames, case51_savedLanguageKeyDetection,
                     case55_recordedBaseCharacter, case62_functionKeyNames,
                     case63_arrowKeyNames, case64_recordedFunctionAndArrowCharacter]
        for test in tests { test() }
        print("PASS: \(tests.count) hotkey key name tests")
    }
}
