import Foundation

final class OAuth2Service {
    private var UnsplashGetAuthTokenURL: URL {
        guard let url = URL(string: UnsplashGetAuthTokenURLString) else {
            preconditionFailure("Unable to construct UnsplashGetAuthTokenURLString")
        }
        return url
    }

    func fetchAuthToken(code: String, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        let postData: [String: Any] = [
            "client_id": AccessKey,
            "client_secret": SecretKey,
            "redirect_uri": RedirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        var req: RequestFactoryProtocol = RequestFactory()

        guard let request = req.createRequest(
            url: UnsplashGetAuthTokenURL,
            method: "POST",
            postData: postData,
            headers: nil,
            queryItemsInURL: true
        ) else { return }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let oauthTokenResponse):
                completion(.success(oauthTokenResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
