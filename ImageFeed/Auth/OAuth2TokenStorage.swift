import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    let key = "Auth token"
    private enum Keys: String {
        case access_token
    }
    var token: String? {
        get {
            if let token = KeychainWrapper.standard.string(forKey: key) {
                return token
            } else {
                return nil
            }
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: key)
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }
}
