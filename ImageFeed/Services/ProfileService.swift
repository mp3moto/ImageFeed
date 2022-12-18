import Foundation

enum ProfileServiceError: Error {
    case emptyToken
    case emptyUsername
    case invalidTokenInFetchProfileData
    case invalidTokenInFetchProfilePhoto
    case networkError
}

extension ProfileServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyToken:
            return NSLocalizedString("Empty Unsplash AuthToken provided", comment: "Please, authorize on Unsplash to get AuthToken")
        case .emptyUsername:
            return NSLocalizedString("Can't get user's photo", comment: "Please check your Unsplash profile")
        case .invalidTokenInFetchProfileData:
            return NSLocalizedString("Invalid Unsplash AuthToken provided in FetchProfileData", comment: "Please, authorize on Unsplash to get valid AuthToken")
        case .invalidTokenInFetchProfilePhoto:
            return NSLocalizedString("Invalid Unsplash AuthToken provided in FetchProfilePhoto", comment: "Please, authorize on Unsplash to get valid AuthToken")
        case .networkError:
            return NSLocalizedString("Network error occured", comment: "")
        }
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private let networkClient: NetworkRouting = NetworkClient()
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    //weak var delegate: SplashViewControllerProtocol?
    
    private var _profile: Profile?
    var profile: Profile? {
        get {
            return _profile
        }
        set {
            _profile = newValue
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
                    completion(.success(profile))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(ProfileServiceError.invalidTokenInFetchProfileData))
                }
            }
            task.resume()
        } else {
            completion(.failure(ProfileServiceError.emptyToken))
        }
    }
}
