//
//  KeyboardModeStatus.swift
//  VKey
//
//  Thông điệp trạng thái chế độ bàn phím.
//

import Foundation

enum KeyboardModeStatus {
    struct Result: Equatable {
        let message: String
        let isWarning: Bool
        let treatsAsJIS: Bool
    }

    static func result(mode: Int, hardwareIsJIS: Bool) -> Result {
        switch mode {
        case 1:
            return Result(message: hardwareIsJIS ? "Luôn gõ kiểu JIS" : "Bạn đang gõ trên bàn phím không phải JIS. Ở chế độ JIS, một số phím sẽ ra sai ký tự.",
                          isWarning: !hardwareIsJIS, treatsAsJIS: true)
        case 2:
            return Result(message: hardwareIsJIS ? "Bạn đang gõ trên bàn phím JIS. Ở chế độ Tiếng Anh, một số phím sẽ ra sai ký tự (vd @ ra ơ) và 英数 / かな không chuyển ngôn ngữ." : "Luôn gõ như bàn phím tiếng Anh (US)",
                          isWarning: hardwareIsJIS, treatsAsJIS: false)
        default:
            return Result(message: hardwareIsJIS ? "Đang nhận: bàn phím JIS — gõ kiểu JIS, dùng được 英数 / かな" : "Đang nhận: bàn phím US / ISO — gõ như bàn phím tiếng Anh",
                          isWarning: false, treatsAsJIS: hardwareIsJIS)
        }
    }
}
