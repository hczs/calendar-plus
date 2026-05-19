import Foundation

enum StatusIconMode: String {
    case fixedIcon
    case todayDate
}

enum ThemeMode: String {
    case system
    case light
    case dark
}

extension Notification.Name {
    static let settingsStoreDidChange = Notification.Name("SettingsStoreDidChange")
}

final class SettingsStore {
    private let userDefaults: UserDefaults
    private let statusIconModeKey = "statusIconMode"
    private let themeModeKey = "themeMode"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var statusIconMode: StatusIconMode {
        get {
            StatusIconMode(rawValue: userDefaults.string(forKey: statusIconModeKey) ?? StatusIconMode.fixedIcon.rawValue) ?? .fixedIcon
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: statusIconModeKey)
            NotificationCenter.default.post(name: .settingsStoreDidChange, object: self)
        }
    }

    var themeMode: ThemeMode {
        get {
            ThemeMode(rawValue: userDefaults.string(forKey: themeModeKey) ?? ThemeMode.system.rawValue) ?? .system
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: themeModeKey)
            NotificationCenter.default.post(name: .settingsStoreDidChange, object: self)
        }
    }
}
