import Foundation

enum ProfileServiceError: Error {
    case emptyToken
    case emptyUsername
    case invalidTokenInFetchProfileData
    case invalidTokenInFetchProfilePhoto
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
        }
    }
}

final class ProfileService {
    private let networkClient: NetworkRouting = NetworkClient()
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    
    private func getAuthToken() -> String? {
        if let token = storage.token {
            return token
        } else {
            return nil
        }
    }
    
    private func fetchProfileData(token: String, completion: @escaping (Result<ProfileResult,Error>) -> Void) {
        self.networkClient.fetch(
            url: ProfileDataURL!,
            method: "GET",
            userData: nil,
            headers: ["Authorization": "Bearer \(token)"],
            queryItemsInURL: false,
            handler: { result in
                print("fetchProfileData processing result")
                switch result {
                case .success(let rawData):
                    do {
                        let JSONtoStruct = try JSONDecoder().decode(ProfileResult.self, from: rawData)
                        completion(.success(JSONtoStruct))
                    } catch {
                        completion(.failure(ProfileServiceError.invalidTokenInFetchProfileData))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
    
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
                            print(String(decoding: rawData, as: UTF8.self))
                            let JSONtoStruct = try JSONDecoder().decode(UsersPublicProfileResult.self, from: rawData)
                            let profile = Profile(
                                username: profileData.username,
                                name: profileData.name(),
                                bio: profileData.bio,
                                image: JSONtoStruct.profile_image.small
                            )
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
                                let dataStorage: DataStorage = DataStorage()
                                dataStorage.profile = profile
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
}
