import Foundation

final class OAuth2Service {
    private var UnsplashGetAuthTokenURL: URL {
        guard let url = URL(string: UnsplashGetAuthTokenURLString) else {
            preconditionFailure("Unable to construct UnsplashGetAuthTokenURLString")
        }
        return url
    }
    private var lastCode: String?
    private var task: URLSessionTask?

    func fetchAuthToken(code: String, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        if task != nil {
            if code != lastCode {
                task?.cancel()
                lastCode = code
            } else {
                return
            }
        } else {
            if code == lastCode {
                return
            }
        }

        let postData: [String: Any] = [
            "client_id": AccessKey,
            "client_secret": SecretKey,
            "redirect_uri": RedirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        let req: RequestFactoryProtocol = RequestFactory()

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
            case .failure:
                completion(.failure(ImageFeedError.invalidCode))
            }
        }
        self.task = task
        task.resume()
    }
}
