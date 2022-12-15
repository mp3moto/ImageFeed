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

/*struct Profile: Codable {
    let username: String?
    let name: String?
    let bio: String?
    let image: String?
}*/
