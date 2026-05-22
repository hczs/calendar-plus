import AppKit

func loadLogo(from root: URL) throws -> NSImage {
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

func renderLogo(_ source: NSImage, size: Int, url: URL) throws {
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

    context.cgContext.clear(CGRect(x: 0, y: 0, width: CGFloat(pixels), height: CGFloat(pixels)))
    let dest = CGRect(x: 0, y: 0, width: CGFloat(pixels), height: CGFloat(pixels))
    source.draw(
        in: dest,
        from: .zero,
        operation: .sourceOver,
        fraction: 1,
        respectFlipped: true,
        hints: [.interpolation: NSImageInterpolation.high]
    )

    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "generate-icons", code: 3)
    }
    try png.write(to: url)
}

func writeIconset(logo: NSImage, iconsetURL: URL) throws {
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
    let logo = try loadLogo(from: root)
    let resources = root.appendingPathComponent("CalendarPlus/Resources", isDirectory: true)
    try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)

    let iconset = resources.appendingPathComponent("AppIcon.iconset", isDirectory: true)
    try? FileManager.default.removeItem(at: iconset)
    try writeIconset(logo: logo, iconsetURL: iconset)

    let icns = resources.appendingPathComponent("AppIcon.icns")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    process.arguments = ["-c", "icns", iconset.path, "-o", icns.path]
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw NSError(domain: "generate-icons", code: Int(process.terminationStatus))
    }
    try? FileManager.default.removeItem(at: iconset)
    print("Wrote icons to \(resources.path)")
}

try main()
