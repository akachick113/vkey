//
//  StatusIcon.swift
//  VKey
//
//  Biểu tượng trạng thái ngôn ngữ trên thanh menu.
//

import AppKit

// Native menu-bar template or vermilion glyph, cached for the six visible states.
enum StatusIcon {
    private static var cache: [String: NSImage] = [:]

    static func image(indicator: LanguageIndicator, gray: Bool, excluded: Bool = false) -> NSImage {
        let key = "\(indicator.menuBarText)-\(gray)-\(excluded)"
        if let image = cache[key] { return image }
        let font = NSFont.systemFont(ofSize: 11, weight: .bold)
        let text = indicator.menuBarText as NSString
        let textSize = text.size(withAttributes: [.font: font])
        let size = NSSize(width: ceil(textSize.width) + 8, height: 18)
        let alpha: CGFloat = excluded ? 0.35 : 1
        // Colour icons deliberately use the light brand token, even in dark menus.
        let appearance = NSAppearance(named: .aqua)!
        var accent = NSColor.black
        var onAccent = NSColor.white
        appearance.performAsCurrentDrawingAppearance {
            accent = NSColor(VKTheme.accent).usingColorSpace(.sRGB)!
            onAccent = NSColor(VKTheme.onAccent).usingColorSpace(.sRGB)!
        }
        let ink = (gray ? NSColor.black : accent).withAlphaComponent(alpha)
        let paper = onAccent.withAlphaComponent(alpha)
        let image = NSImage(size: size, flipped: false) { rect in
            let frame = NSBezierPath(roundedRect: rect.insetBy(dx: 0.75, dy: 0.75), xRadius: 3.5, yRadius: 3.5)
            ink.set()
            if indicator == .vietnamese { frame.fill() }
            else { frame.lineWidth = 1.5; frame.stroke() }
            let point = NSPoint(x: rect.midX - textSize.width / 2, y: rect.midY - textSize.height / 2)
            if gray && indicator == .vietnamese {
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current?.compositingOperation = .destinationOut
                text.draw(at: point, withAttributes: [.font: font, .foregroundColor: NSColor.black])
                NSGraphicsContext.restoreGraphicsState()
            } else {
                text.draw(at: point, withAttributes: [.font: font, .foregroundColor: indicator == .vietnamese ? paper : ink])
            }
            return true
        }
        image.isTemplate = gray
        cache[key] = image
        return image
    }
}
