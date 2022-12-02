import Foundation

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let refresh_token: String
    let scope: String
    let created_at: Double
}

struct UnsplashProfileData: Decodable {
    let id: String
    let username: String
    let first_name: String
    let last_name: String
    let bio: String
}
