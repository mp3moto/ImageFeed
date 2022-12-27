import Foundation

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let refresh_token: String
    let scope: String
    let created_at: Double
}

struct Profile: Decodable {
    let id: String?
    let username: String?
    let first_name: String?
    let last_name: String?
    let bio: String?

    func name() -> String? {
        var output: String?
        if let name = self.first_name {
            output = "\(name)"
            if let lastname = self.last_name {
                output = "\(output!) \(lastname)"
            }
        } else {
            if let lastname = self.last_name {
                output = "\(lastname)"
            }
        }
        return output
    }
}

struct ProfileImage: Decodable {
    let large: String
}

struct UserResult: Decodable {
    let profile_image: ProfileImage
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
    /*
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String?, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
     */
}

struct UrlsResult: Codable {
    let regular: String?
    let full: String?
    let small: String?
}

struct PhotoResult: Codable {
    let id: String?
    let width: Int?
    let height: Int?
    let created_at: String?
    let liked_by_user: Bool?
    let description: String?
    let urls: UrlsResult?
}

struct LikeResult: Codable {
    let photo: PhotoResult
}
