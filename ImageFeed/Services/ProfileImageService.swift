import Foundation

final class ProfileImageService {
    static let profileService = ProfileService.shared
    private let networkClient: NetworkRouting = NetworkClient()
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var _avatarURL: String? {
        didSet {
            if let avatar = _avatarURL {
                print("AvatarURL is \(avatar)")
            }
        }
    }
    var avatarURL: String? {
        get {
            return _avatarURL
        }
        set {
            _avatarURL = newValue
        }
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<UserResult,Error>) -> Void) {
        if let token = storage.token {
            let PublicProfileURL = URL(string: "https://api.unsplash.com/users/\(username)")
            print("username is \(username)")
            self.networkClient.fetch(
                url: PublicProfileURL!,
                method: "GET",
                userData: nil,
                headers: ["Authorization": "Bearer \(token)"],
                queryItemsInURL: false,
                handler: { result in
                    print("used token is \(token)")
                    switch result {
                    case .success(let rawData):
                        do {
                            let JSONtoStruct = try JSONDecoder().decode(UserResult.self, from: rawData)
                            self.avatarURL = JSONtoStruct.profile_image.large
                            completion(.success(JSONtoStruct))
                            if let avatarURL = self.avatarURL {
                                NotificationCenter.default.post(
                                    name: ProfileImageService.DidChangeNotification,
                                    object: self,
                                    userInfo: ["URL": avatarURL]
                                )
                            }
                        } catch {
                            completion(.failure(ProfileServiceError.invalidTokenInFetchProfilePhoto))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
    }
}
