import AppKit

enum AppBrandResources {
    /// macOS 菜单栏模板图标：SF Symbol 单色线条，随系统深浅色自动反色。
    static func statusBarIcon() -> NSImage? {
        let configuration = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        guard let image = NSImage(
            systemSymbolName: "calendar",
            accessibilityDescription: "CalendarPlus"
        )?.withSymbolConfiguration(configuration) else {
            return nil
        }
        image.isTemplate = true
        return image
    }
}
