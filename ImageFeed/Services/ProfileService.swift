import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    //private let profileImageService = ProfileImageService.shared

    private var tempProfile: Profile?
    var profile: Profile? {
        get {
            return tempProfile
        }
        set {
            tempProfile = newValue
        }
    }

    func fetchProfile(completion: @escaping (Result<Profile,Error>) -> Void) {
        if let token = storage.token {
            let req: RequestFactoryProtocol = RequestFactory()
            guard let request = req.createRequest(
                url: ProfileDataURL!,
                method: "GET",
                postData: nil,
                headers: ["Authorization": "Bearer \(token)"],
                queryItemsInURL: false
            ) else { return }
            let session = URLSession.shared
            let task = session.objectTask(for: request) { (result: Result<Profile, Error>) in
                switch result {
                case .success(let profile):
                    self.profile = profile
                    guard let _ = profile.username else { return }
                    completion(.success(profile))
                case .failure:
                    completion(.failure(ImageFeedError.invalidToken))
                }
            }
            task.resume()
        } else {
            completion(.failure(ImageFeedError.emptyToken))
        }
    }
}
