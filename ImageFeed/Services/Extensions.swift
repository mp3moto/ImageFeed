import Foundation

enum NetworkError: Error {
    case codeError
    case dataError
}

extension URLError {
    func errorDescription() -> String {
        var message: String
        switch code {
        case .cancelled:
          message = "Сервер разорвал соединение"
        case .cannotFindHost:
            message = "Не удается найти сервер"
        case .notConnectedToInternet:
            message = "Нет соединения с интернетом"
        case .resourceUnavailable:
            message = "Сайт Unsplash недоступен"
        case .timedOut:
            message = "Превышен лимит времени"
        default:
            message = "Неизвестная ошибка с кодом: \(code)"
        }
        return message
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(NetworkError.codeError))
            }
            guard let data = data else {
                return
            }
            do {
                let JSONtoStruct = try JSONDecoder().decode(T.self, from: data)
                completion(.success(JSONtoStruct))
            } catch {
                completion(.failure(NetworkError.dataError))
            }
        })
        return task
    }
}
