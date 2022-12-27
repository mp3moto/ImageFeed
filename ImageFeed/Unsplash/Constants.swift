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
let PhotosDataURL = URL(string: "https://api.unsplash.com/photos")
