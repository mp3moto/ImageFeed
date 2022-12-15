import Foundation

final class DataStorage {
    /*
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case profile
    }
    var profile: Profile? {
        get {
            guard let data = userDefaults.data(forKey: Keys.profile.rawValue),
                  let profile = try? JSONDecoder().decode(Profile.self, from: data) else {
                    return nil
                }
            return .init(username: profile.username, name: profile.name, bio: profile.bio, image: profile.image)
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Unable to store the result")
                return
            }
            userDefaults.set(data, forKey: Keys.profile.rawValue)
        }
    }
     */
}
