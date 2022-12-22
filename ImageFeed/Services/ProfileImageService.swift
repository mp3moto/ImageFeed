import Foundation

final class ProfileImageService {
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var tempAvatarURL: String?
    var avatarURL: String? {
        get {
            return tempAvatarURL
        }
        set {
            tempAvatarURL = newValue
        }
    }

    func fetchProfileImageURL(username: String, completion: @escaping (Result<UserResult,Error>) -> Void) {
        if let token = storage.token {
            guard let publicProfileURL = URL(string: "https://api.unsplash.com/users/\(username)") else {
                completion(.failure(ImageFeedError.invalidProfileURL))
                return
            }

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
                case .failure:
                    completion(.failure(ImageFeedError.invalidAvatar))
                }
            }
            task.resume()
        } else {
            completion(.failure(ImageFeedError.emptyToken))
        }
    }
}
