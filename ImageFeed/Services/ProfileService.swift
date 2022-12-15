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
    weak var delegate: SplashViewControllerProtocol?
    
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
            self.networkClient.fetch(
                url: ProfileDataURL!,
                method: "GET",
                userData: nil,
                headers: ["Authorization": "Bearer \(token)"],
                queryItemsInURL: false,
                handler: { result in
                    //print("fetchProfileData processing result")
                    switch result {
                    case .success(let rawData):
                        do {
                            let JSONtoStruct = try JSONDecoder().decode(Profile.self, from: rawData)
                            self.profile = JSONtoStruct
                            completion(.success(JSONtoStruct))
                        } catch {
                            completion(.failure(ProfileServiceError.invalidTokenInFetchProfileData))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        } else {
            completion(.failure(ProfileServiceError.emptyToken))
        }
    }
    /*
    private func fetchProfilePhoto(token: String, profileData: ProfileResult, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let username = profileData.username {
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
                            let JSONtoStruct = try JSONDecoder().decode(UsersPublicProfileResult.self, from: rawData)
                            
                            self.delegate?.showImageFeed()
                            let profile = Profile(
                                username: profileData.username,
                                name: profileData.name(),
                                bio: profileData.bio,
                                image: JSONtoStruct.profile_image.large
                            )
                            self.profileImageService.avatarURL = JSONtoStruct.profile_image.large
                            completion(.success(profile))
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
     */
    /*
    func getProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        if let token = getAuthToken() {
            fetchProfileData(
                token: token,
                completion: { result in
                    switch result {
                    case .success(let profileData):
                        self.fetchProfilePhoto(token: token,
                                               profileData: profileData,
                                               completion: { result in
                            switch result {
                            case .success(let profile):
                                self.profile = profile
                                completion(.success(profile))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        })
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        } else {
            completion(.failure(ProfileServiceError.emptyToken))
        }
    }
     */
}
