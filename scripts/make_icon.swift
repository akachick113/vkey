// Flat V + acute accent and Japanese seal, in the DESIGN §9 coordinate space.
// Usage: swift scripts/make_icon.swift <output-appiconset-dir>
import AppKit
import Foundation

let outDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Sources/Support/Assets.xcassets/AppIcon.appiconset"
try FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func renderIcon(pixels: Int) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                               isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let context = NSGraphicsContext.current!.cgContext
    let side = CGFloat(pixels)
    let scale = side / 144
    context.scaleBy(x: scale, y: scale)
    let brand = NSColor(srgbRed: 0xC2 / 255.0, green: 0x41 / 255.0, blue: 0x2B / 255.0, alpha: 1)
    let paper = NSColor(srgbRed: 0xFF / 255.0, green: 0xFD / 255.0, blue: 0xF9 / 255.0, alpha: 1)
    let width: CGFloat = 144 * 824 / 1024
    let inset = (144 - width) / 2
    let background = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: width, height: width),
                                  xRadius: width * 0.225, yRadius: width * 0.225)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shadow.shadowBlurRadius = 3
    shadow.shadowOffset = NSSize(width: 0, height: -1)
    shadow.set()
    brand.setFill()
    background.fill()
    NSGraphicsContext.restoreGraphicsState()

    // The 112-point drawing lives in a centred 144-point canvas; flip SVG y.
    func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint { NSPoint(x: 16 + x, y: 144 - 16 - y) }
    paper.setStroke()
    let v = NSBezierPath()
    v.move(to: point(24, 34)); v.line(to: point(52, 86)); v.line(to: point(80, 34))
    v.lineWidth = pixels <= 32 ? 14 : 12
    v.lineCapStyle = .round; v.lineJoinStyle = .round; v.stroke()
    let acute = NSBezierPath()
    acute.move(to: point(56, 22)); acute.line(to: point(70, 11))
    acute.lineWidth = pixels <= 32 ? 10 : 9
    acute.lineCapStyle = .round; acute.stroke()
    if pixels > 32 {
        let center = point(86, 84)
        paper.setFill()
        NSBezierPath(ovalIn: NSRect(x: center.x - 17, y: center.y - 17, width: 34, height: 34)).fill()
        let text = "あ" as NSString
        let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 19, weight: .bold), .foregroundColor: brand]
        let size = text.size(withAttributes: attributes)
        text.draw(at: NSPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), withAttributes: attributes)
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let sizes: [(name: String, points: Int, scale: Int)] = [
    ("icon_16x16", 16, 1), ("icon_16x16@2x", 16, 2),
    ("icon_32x32", 32, 1), ("icon_32x32@2x", 32, 2),
    ("icon_128x128", 128, 1), ("icon_128x128@2x", 128, 2),
    ("icon_256x256", 256, 1), ("icon_256x256@2x", 256, 2),
    ("icon_512x512", 512, 1), ("icon_512x512@2x", 512, 2),
]

var images: [[String: String]] = []
for entry in sizes {
    let px = entry.points * entry.scale
    let rep = renderIcon(pixels: px)
    let data = rep.representation(using: .png, properties: [:])!
    let filename = "\(entry.name).png"
    try! data.write(to: URL(fileURLWithPath: "\(outDir)/\(filename)"))
    images.append([
        "filename": filename,
        "idiom": "mac",
        "scale": "\(entry.scale)x",
        "size": "\(entry.points)x\(entry.points)",
    ])
}

let contents: [String: Any] = [
    "images": images,
    "info": ["author": "xcode", "version": 1],
]
let json = try! JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try! json.write(to: URL(fileURLWithPath: "\(outDir)/Contents.json"))
print("AppIcon written to \(outDir)")
