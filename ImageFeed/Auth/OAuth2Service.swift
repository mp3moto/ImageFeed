import Foundation

final class OAuth2Service {
    private let networkClient: NetworkRouting
    private var UnsplashGetAuthTokenURL: URL {
        guard let url = URL(string: UnsplashGetAuthTokenURLString) else {
            preconditionFailure("Unable to construct UnsplashGetAuthTokenURLString")
        }
        return url
    }
    private var lastCode: String?

    func fetchAuthToken(code: String, delay: Int, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        //print("delay is \(delay) and code is \(code)")
        // assert(Thread.isMainThread)
        var allowToSendRequest: Bool = false
        if self.lastCode == code { return }
        else {
            allowToSendRequest = true
            self.lastCode = code
        }
        if allowToSendRequest {
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
                    //DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delay)) {
                        //print("execution after delay \(delay)")
                        //print("\(self.lastCode) == \(code)")
                        //В общем, здесь так просто не удается создать ситуацию гонки. Даже при 2 запросах, второй из которых заканчивается раньше первого token остается валидным
                        //if self.lastCode == code {
                            do {
                                let JSONtoStruct = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: rawData)
                                completion(.success(JSONtoStruct))
                            } catch {
                                completion(.failure(error))
                            }
                        //}
                    //}
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }

    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
}
