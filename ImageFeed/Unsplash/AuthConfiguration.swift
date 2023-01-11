import Foundation

let API = "https://api.unsplash.com"
let AccessKey = "vnjUVjk49kTxqkm7ZlQHdDRF4y-zN76oeauaYPxwQqM"
let SecretKey = "7pURZ06ClZzM75tQnXWxhzF4UgG17jAoMviBAdUmY-I"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: API)
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let UnsplashGetAuthTokenURLString = "https://unsplash.com/oauth/token"
let ProfileDataURL = URL(string: "https://api.unsplash.com/me")
let showAuthViewSegueIdentifier = "ShowAuthView"
let showSplashViewSegueIdentifier = "ShowSplashView"
let showTabBarViewSegueIdentifier = "ShowTabBarView"
let PhotosDataURLString = "https://api.unsplash.com/photos"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScore: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScore
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScore: AccessKey,
                                 defaultBaseURL: DefaultBaseURL!,
                                 authURLString: UnsplashAuthorizeURLString)
    }
}
