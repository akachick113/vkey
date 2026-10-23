//
//  LanguageIndicator.swift
//  VKey
//
//  Trạng thái ngôn ngữ đang gõ.
//

import Foundation

enum LanguageIndicator: Equatable {
    case vietnamese, english, japanese

    static func current(isVietnamese: Bool, inputSourceIsLatin: Bool) -> LanguageIndicator {
        inputSourceIsLatin ? (isVietnamese ? .vietnamese : .english) : .japanese
    }

    var menuBarText: String {
        switch self {
        case .vietnamese: return "VI"
        case .english: return "EN"
        case .japanese: return "あ"
        }
    }
}
