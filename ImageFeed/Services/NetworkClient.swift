import Foundation

protocol NetworkRouting {
    func fetch(url: URL, method: String?, userData: [String: Any]?, headers: [String: Any]?, queryItemsInURL: Bool, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
    }

    func fetch(url: URL, method: String?, userData: [String: Any]?, headers: [String: Any]?, queryItemsInURL: Bool = false, handler: @escaping (Result<Data, Error>) -> Void) {
        var httpMethod: String
        var urlComponents: URLComponents
        if let method = method {
            switch method {
            case "POST":
                httpMethod = method
                break
            default:
                httpMethod = "GET"
            }
        }
        else {
            httpMethod = "GET"
        }

        var postData: [String: String] = [:]
        var queryItems: [URLQueryItem] = []
        var httpHeaders: [String: String] = [:]
        var request = URLRequest(url: url)
        if let userData = userData {
            postData = userData.mapValues { String(describing: $0) }
        }
        if let headers = headers {
            httpHeaders = headers.mapValues { String(describing: $0) }
        }
        urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if httpMethod == "GET" || (httpMethod == "POST" && queryItemsInURL == true) {
            for (key, value) in postData {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
        } else {
            for (key, value) in postData {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
            if let query = urlComponents.url!.query {
                request.httpBody = Data(query.utf8)
            }
        }

        let url = urlComponents.url!
        request = URLRequest(url: url)
        request.httpMethod = httpMethod

        for (key, value) in httpHeaders {
            request.addValue("Bearer \(value)", forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            guard let data = data else {
                return
            }
            handler(.success(data))
        }
        task.resume()
    }
}
