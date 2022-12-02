import Foundation

final class OAuth2Service {
    private let networkClient: NetworkRouting
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
        self.networkClient.fetch(url: self.UnsplashGetAuthTokenURL, method: "POST", userData: postData, headers: nil, queryItemsInURL: true, handler: { result in
            switch result {
            case .success(let rawData):
                do {
                    let JSONtoStruct = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: rawData)
                    completion(.success(JSONtoStruct))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
}
