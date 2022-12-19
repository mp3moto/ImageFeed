import Foundation

enum NetworkError: Error {
    case codeError
    case dataError
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
