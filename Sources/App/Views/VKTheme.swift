//
//  VKTheme.swift
//  VKey
//
//  Bảng màu động dùng chung cho giao diện sáng và tối.
//

import SwiftUI

enum VKTheme {
    private static func color(_ name: String, _ light: UInt32, _ dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: NSColor.Name(name)) { appearance in
            let value = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: CGFloat((value >> 16) & 255) / 255,
                           green: CGFloat((value >> 8) & 255) / 255,
                           blue: CGFloat(value & 255) / 255, alpha: 1)
        })
    }

    static let windowBackground = color("windowBackground", 0xFBF8F3, 0x1E1B19)
    static let sidebarBackground = color("sidebarBackground", 0xF3EDE3, 0x252120)
    static let card = color("card", 0xFFFDF9, 0x2B2623)
    static let border = color("border", 0xE4DACB, 0x3D3530)
    static let divider = color("divider", 0xEFE7DA, 0x342E2A)
    static let textPrimary = color("textPrimary", 0x2B2724, 0xF2ECE4)
    static let textSecondary = color("textSecondary", 0x6E6458, 0xB5A99A)
    static let accent = color("accent", 0xC2412B, 0xE0583F)
    static let accentText = color("accentText", 0xA8341F, 0xF08A72)
    static let onAccent = color("onAccent", 0xFFFDF9, 0xFFFDF9)
    static let keycapBorder = color("keycapBorder", 0xCDBFAA, 0x574C43)
    static let segmentTrack = color("segmentTrack", 0xF3EDE3, 0x332D29)
    static let segmentThumb = color("segmentThumb", 0xFFFDF9, 0x4A403A)
    static let ok = color("ok", 0x3F8F4E, 0x6CC07A)
    static let warningBackground = color("warningBackground", 0xFBEBDD, 0x3A2A1C)
    static let warningBorder = color("warningBorder", 0xEBC7A6, 0x6B4A2C)
    static let warningText = color("warningText", 0x5A3A1E, 0xF2D3B5)
    static let warningIcon = color("warningIcon", 0xA35A1C, 0xE9A06A)
}
