import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case access_token
    }
    var token: String? {
        get {
            if let access_token = userDefaults.string(forKey: Keys.access_token.rawValue) {
                return access_token
            } else {
                return nil
            }
        }
        set {
            userDefaults.set(newValue, forKey: Keys.access_token.rawValue)
        }
    }
}
