import Foundation

final class ProfileImageService {
    static let profileService = ProfileService.shared
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var _avatarURL: String?
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
            guard let publicProfileURL = URL(string: "https://api.unsplash.com/users/\(username)") else {
                completion(.failure(ProfileServiceError.invalidTokenInFetchProfilePhoto))
                print("guard catched")
                return
            }
            print("guard passed")
            let req: RequestFactoryProtocol = RequestFactory()

            guard let request = req.createRequest(
                url: publicProfileURL,
                method: "GET",
                postData: nil,
                headers: ["Authorization": "Bearer \(token)"],
                queryItemsInURL: false
            ) else { return }
            let session = URLSession.shared
            let task = session.objectTask(for: request) { (result: Result<UserResult, Error>) in
                switch result {
                case .success(let userResult):
                    self.avatarURL = userResult.profile_image.large

                    if let avatarURL = self.avatarURL {
                        NotificationCenter.default.post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL]
                        )
                    }
                    completion(.success(userResult))
                case .failure(_):
                    completion(.failure(ProfileServiceError.invalidTokenInFetchProfilePhoto))
                }
            }
            task.resume()
        } else {
            completion(.failure(ProfileServiceError.emptyToken))
        }
    }
}
