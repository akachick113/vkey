import Foundation

@main
struct KeyboardModeStatusTests {
    static func case74_autoModeStatus() {
        precondition(KeyboardModeStatus.result(mode: 0, hardwareIsJIS: true) == .init(
            message: "Đang nhận: bàn phím JIS — gõ kiểu JIS, dùng được 英数 / かな", isWarning: false, treatsAsJIS: true))
        precondition(KeyboardModeStatus.result(mode: 0, hardwareIsJIS: false) == .init(
            message: "Đang nhận: bàn phím US / ISO — gõ như bàn phím tiếng Anh", isWarning: false, treatsAsJIS: false))
    }
    static func case75_forcedModeMatchingKeyboard() {
        precondition(KeyboardModeStatus.result(mode: 1, hardwareIsJIS: true) == .init(
            message: "Luôn gõ kiểu JIS", isWarning: false, treatsAsJIS: true))
        precondition(KeyboardModeStatus.result(mode: 2, hardwareIsJIS: false) == .init(
            message: "Luôn gõ như bàn phím tiếng Anh (US)", isWarning: false, treatsAsJIS: false))
    }
    static func case76_forcedModeMismatchWarns() {
        precondition(KeyboardModeStatus.result(mode: 1, hardwareIsJIS: false) == .init(
            message: "Bạn đang gõ trên bàn phím không phải JIS. Ở chế độ JIS, một số phím sẽ ra sai ký tự.", isWarning: true, treatsAsJIS: true))
        precondition(KeyboardModeStatus.result(mode: 2, hardwareIsJIS: true) == .init(
            message: "Bạn đang gõ trên bàn phím JIS. Ở chế độ Tiếng Anh, một số phím sẽ ra sai ký tự (vd @ ra ơ) và 英数 / かな không chuyển ngôn ngữ.", isWarning: true, treatsAsJIS: false))
    }
    static func case77_invalidModeFallsBackToAuto() {
        for mode in [3, -1] {
            for hardware in [false, true] {
                precondition(KeyboardModeStatus.result(mode: mode, hardwareIsJIS: hardware) == KeyboardModeStatus.result(mode: 0, hardwareIsJIS: hardware))
            }
        }
    }
    static func case78_languageIndicator() {
        precondition(LanguageIndicator.current(isVietnamese: true, inputSourceIsLatin: true) == .vietnamese)
        precondition(LanguageIndicator.current(isVietnamese: false, inputSourceIsLatin: true) == .english)
        for vietnamese in [false, true] {
            precondition(LanguageIndicator.current(isVietnamese: vietnamese, inputSourceIsLatin: false) == .japanese)
        }
        precondition(LanguageIndicator.vietnamese.menuBarText == "VI")
        precondition(LanguageIndicator.english.menuBarText == "EN")
        precondition(LanguageIndicator.japanese.menuBarText == "あ")
    }
    static func main() {
        let tests = [case74_autoModeStatus, case75_forcedModeMatchingKeyboard, case76_forcedModeMismatchWarns,
                     case77_invalidModeFallsBackToAuto, case78_languageIndicator]
        for test in tests { test() }
        print("PASS: \(tests.count) keyboard mode tests")
    }
}
