import Foundation

enum ImageFeedError: Error {
    case emptyToken
    case emptyUsername
    case invalidAvatar
    case invalidCode
    case invalidToken
    case invalidProfileURL
    case networkError
    case dataError
}

extension ImageFeedError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyToken:
            return NSLocalizedString("Пустой токен авторизации", comment: "")
        case .emptyUsername:
            return NSLocalizedString("Некорректное имя пользователя", comment: "")
        case .invalidCode:
            return NSLocalizedString("Некорректный код авторизации", comment: "")
        case .invalidProfileURL:
            return NSLocalizedString("Некорректный адрес страницы пользователя", comment: "")
        case .networkError:
            return NSLocalizedString("Ошибка сети", comment: "")
        case .invalidToken:
            return NSLocalizedString("Недействительный токен авторизации", comment: "")
        case .invalidAvatar:
            return NSLocalizedString("Не удалось загрузить аватар пользователя", comment: "")
        case .dataError:
            return NSLocalizedString("Некорректный формат данных с сервера", comment: "")
        }
    }
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
                completion(.failure(ImageFeedError.networkError))
            }
            guard let data = data else {
                return
            }
            do {
                let JSONtoStruct = try JSONDecoder().decode(T.self, from: data)
                completion(.success(JSONtoStruct))
            } catch {
                completion(.failure(ImageFeedError.dataError))
            }
        })
        return task
    }
}
