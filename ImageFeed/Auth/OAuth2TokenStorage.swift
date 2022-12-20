import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    private let delegate: KeychainEventsProtocol?
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
                let result = KeychainWrapper.standard.set(token, forKey: key)
                if result == false { keychainError() } else { print("token stored in keychain") }
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }

    init(delegate: KeychainEventsProtocol? = nil) {
        self.delegate = delegate
    }

    func keychainError() {
        delegate?.keychainError()
    }
    
    
}
