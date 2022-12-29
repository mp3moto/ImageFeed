import Foundation

final class RequestFactory: RequestFactoryProtocol {
    func createRequest(url: URL, method: String, postData: [String : Any]?, headers: [String : Any]?, queryItemsInURL: Bool) -> URLRequest? {

        var httpMethod: String
        switch method {
        case "POST", "DELETE":
            httpMethod = method
        default:
            httpMethod = "GET"
        }

        var userData: [String: String] = [:]
        if let postData = postData {
            userData = postData.mapValues { String(describing: $0) }
        }

        var httpHeaders: [String: String] = [:]
        if let headers = headers {
            httpHeaders = headers.mapValues { String(describing: $0) }
        }

        var urlComponents: URLComponents
        urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        var queryItems: [URLQueryItem] = []
        for (key, value) in userData {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems

        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod

            if httpMethod == "POST" && queryItemsInURL == false {
                if let query = urlComponents.url!.query {
                    request.httpBody = Data(query.utf8)
                }
            }

            for (key, value) in httpHeaders {
                request.addValue("Bearer \(value)", forHTTPHeaderField: key)
            }

            return request
        } else {
            return nil
        }
    }
}
