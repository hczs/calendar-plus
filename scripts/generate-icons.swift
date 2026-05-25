import AppKit

fileprivate struct RGB {
    var r: Double
    var g: Double
    var b: Double
}

/// macOS squircle mask uses ~22.37% corner radius on app icons.
fileprivate let squircleCornerFraction: CGFloat = 0.2237
/// Keep artwork slightly inside the mask so corners are not clipped in Dock.
fileprivate let artworkInsetFraction: CGFloat = 0.06

fileprivate func loadLogo(from root: URL) throws -> NSImage {
    let logoURL = root.appendingPathComponent("Brand/logo.jpeg")
    guard let image = NSImage(contentsOf: logoURL) else {
        throw NSError(
            domain: "generate-icons",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Missing or unreadable logo at \(logoURL.path)"]
        )
    }
    return image
}

fileprivate func cgImage(from image: NSImage) -> CGImage? {
    var rect = CGRect(origin: .zero, size: image.size)
    return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
}

fileprivate func averageCornerColor(cgImage: CGImage, sample: Int = 20) -> RGB {
    let w = cgImage.width
    let h = cgImage.height
    let s = min(sample, min(w, h) / 4)
    let corners: [(Int, Int)] = [
        (0, 0), (w - s, 0), (0, h - s), (w - s, h - s),
    ]
    var sumR = 0.0, sumG = 0.0, sumB = 0.0, count = 0.0
    guard let data = cgImage.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else {
        return RGB(r: 255, g: 255, b: 255)
    }
    let bpp = cgImage.bitsPerPixel / 8
    let bpr = cgImage.bytesPerRow
    for (ox, oy) in corners {
        for y in oy ..< (oy + s) {
            for x in ox ..< (ox + s) {
                let offset = y * bpr + x * bpp
                sumR += Double(bytes[offset])
                sumG += Double(bytes[offset + 1])
                sumB += Double(bytes[offset + 2])
                count += 1
            }
        }
    }
    return RGB(r: sumR / count, g: sumG / count, b: sumB / count)
}

fileprivate func contentBounds(cgImage: CGImage, background: RGB, tolerance: Double = 35) -> CGRect? {
    guard let data = cgImage.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else {
        return nil
    }
    let w = cgImage.width
    let h = cgImage.height
    let bpp = cgImage.bitsPerPixel / 8
    let bpr = cgImage.bytesPerRow
    var minX = w, minY = h, maxX = 0, maxY = 0
    var found = false
    for y in 0 ..< h {
        for x in 0 ..< w {
            let offset = y * bpr + x * bpp
            let r = Double(bytes[offset])
            let g = Double(bytes[offset + 1])
            let b = Double(bytes[offset + 2])
            let dr = r - background.r
            let dg = g - background.g
            let db = b - background.b
            let dist = (dr * dr + dg * dg + db * db).squareRoot()
            if dist > tolerance {
                found = true
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }
    }
    guard found, maxX > minX, maxY > minY else { return nil }
    let pad = Int(Double(min(w, h)) * 0.02)
    let x0 = max(0, minX - pad)
    let y0 = max(0, minY - pad)
    let x1 = min(w - 1, maxX + pad)
    let y1 = min(h - 1, maxY + pad)
    return CGRect(x: x0, y: y0, width: x1 - x0 + 1, height: y1 - y0 + 1)
}

fileprivate func prepareLogo(_ source: NSImage) throws -> NSImage {
    guard let cg = cgImage(from: source) else {
        throw NSError(domain: "generate-icons", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not read logo bitmap"])
    }
    let background = averageCornerColor(cgImage: cg)
    guard let bounds = contentBounds(cgImage: cg, background: background),
          let cropped = cg.cropping(to: bounds) else {
        return source
    }
    let image = NSImage(cgImage: cropped, size: NSSize(width: cropped.width, height: cropped.height))
    image.isTemplate = false
    return image
}

fileprivate func squirclePath(in rect: CGRect) -> CGPath {
    let radius = min(rect.width, rect.height) * squircleCornerFraction
    return CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

fileprivate func aspectFillRect(contentSize: NSSize, in dest: CGRect) -> CGRect {
    let scale = max(dest.width / contentSize.width, dest.height / contentSize.height)
    let w = contentSize.width * scale
    let h = contentSize.height * scale
    return CGRect(
        x: dest.midX - w / 2,
        y: dest.midY - h / 2,
        width: w,
        height: h
    )
}

fileprivate func renderLogo(_ source: NSImage, size: Int, url: URL) throws {
    let pixels = size
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: pixels, height: pixels)

    guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
        throw NSError(domain: "generate-icons", code: 2)
    }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    defer { NSGraphicsContext.restoreGraphicsState() }

    let canvas = CGRect(x: 0, y: 0, width: CGFloat(pixels), height: CGFloat(pixels))
    context.cgContext.clear(canvas)

    context.cgContext.saveGState()
    context.cgContext.addPath(squirclePath(in: canvas))
    context.cgContext.clip()

    let inset = CGFloat(pixels) * artworkInsetFraction
    let dest = canvas.insetBy(dx: inset, dy: inset)
    let drawRect = aspectFillRect(contentSize: source.size, in: dest)
    source.draw(
        in: drawRect,
        from: .zero,
        operation: .sourceOver,
        fraction: 1,
        respectFlipped: true,
        hints: [.interpolation: NSImageInterpolation.high]
    )
    context.cgContext.restoreGState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "generate-icons", code: 3)
    }
    try png.write(to: url)
}

fileprivate func writePreparedBrandPNG(logo: NSImage, root: URL) throws {
    let url = root.appendingPathComponent("Brand/logo-prepared.png")
    try renderLogo(logo, size: 1024, url: url)
}

/// Xcode `AppIcon.appiconset` filenames → `iconutil` `.iconset` filenames.
fileprivate let appIconsetToIconset: [(String, String)] = [
    ("icon_16pt@1x.png", "icon_16x16.png"),
    ("icon_16pt@2x.png", "icon_16x16@2x.png"),
    ("icon_32pt@1x.png", "icon_32x32.png"),
    ("icon_32pt@2x.png", "icon_32x32@2x.png"),
    ("icon_128pt@1x.png", "icon_128x128.png"),
    ("icon_128pt@2x.png", "icon_128x128@2x.png"),
    ("icon_256pt@1x.png", "icon_256x256.png"),
    ("icon_256pt@2x.png", "icon_256x256@2x.png"),
    ("icon_512pt@1x.png", "icon_512x512.png"),
    ("icon_512pt@2x.png", "icon_512x512@2x.png"),
]

fileprivate func appIconsetURL(root: URL) -> URL {
    root.appendingPathComponent("Brand/AppIcon.appiconset", isDirectory: true)
}

fileprivate func appIconsetIsComplete(at url: URL) -> Bool {
    let fm = FileManager.default
    guard fm.fileExists(atPath: url.path) else { return false }
    return appIconsetToIconset.allSatisfy { fm.fileExists(atPath: url.appendingPathComponent($0.0).path) }
}

fileprivate func writeIconsetFromAppIconset(root: URL, iconsetURL: URL) throws {
    let source = appIconsetURL(root: root)
    try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
    for (from, to) in appIconsetToIconset {
        let src = source.appendingPathComponent(from)
        let dst = iconsetURL.appendingPathComponent(to)
        try FileManager.default.copyItem(at: src, to: dst)
    }
}

fileprivate func writeIcns(from iconsetURL: URL, icnsURL: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw NSError(domain: "generate-icons", code: Int(process.terminationStatus))
    }
}

fileprivate func writeIconset(logo: NSImage, iconsetURL: URL) throws {
    let sizes: [(String, Int)] = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
    ]
    try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
    for (name, size) in sizes {
        try renderLogo(logo, size: size, url: iconsetURL.appendingPathComponent(name))
    }
}

func main() throws {
    let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    let resources = root.appendingPathComponent("CalendarPlus/Resources", isDirectory: true)
    try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)

    let iconset = resources.appendingPathComponent("AppIcon.iconset", isDirectory: true)
    let icns = resources.appendingPathComponent("AppIcon.icns")
    try? FileManager.default.removeItem(at: iconset)

    if appIconsetIsComplete(at: appIconsetURL(root: root)) {
        try writeIconsetFromAppIconset(root: root, iconsetURL: iconset)
        try writeIcns(from: iconset, icnsURL: icns)
        try? FileManager.default.removeItem(at: iconset)
        print("Wrote \(icns.path) from Brand/AppIcon.appiconset")
        return
    }

    let raw = try loadLogo(from: root)
    let logo = try prepareLogo(raw)
    try writePreparedBrandPNG(logo: logo, root: root)
    try writeIconset(logo: logo, iconsetURL: iconset)
    try writeIcns(from: iconset, icnsURL: icns)
    try? FileManager.default.removeItem(at: iconset)
    print("Wrote icons to \(resources.path)")
    print("Wrote preview to \(root.appendingPathComponent("Brand/logo-prepared.png").path)")
}

try main()
