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
        print("fetchProfileImageURL called")
        if let token = storage.token {
            let PublicProfileURL = URL(string: "https://api.unsplash.com/users/\(username)")
            //print("username is \(username)")
            
            let req: RequestFactoryProtocol = RequestFactory()
            guard let request = req.createRequest(
                url: PublicProfileURL!,
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
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(ProfileServiceError.invalidTokenInFetchProfilePhoto))
                }
                
            }
            task.resume()
        } else {
            completion(.failure(ProfileServiceError.emptyToken))
        }
    }
}
