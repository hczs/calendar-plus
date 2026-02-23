import Foundation

enum StatusIconMode: String {
    case fixedIcon
    case todayDate
}

final class SettingsStore {
    private let userDefaults: UserDefaults
    private let key = "statusIconMode"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var statusIconMode: StatusIconMode {
        get {
            StatusIconMode(rawValue: userDefaults.string(forKey: key) ?? StatusIconMode.fixedIcon.rawValue) ?? .fixedIcon
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: key)
        }
    }
}
