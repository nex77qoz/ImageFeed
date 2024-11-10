import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case noData
}

extension URLSession {
    func dataTask(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[dataTask]: NetworkError.urlRequestError - \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("[dataTask]: NetworkError.urlSessionError - Некорректный формат ответа")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                if 200...299 ~= response.statusCode {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        print("[dataTask]: NetworkError.noData - Данные отсутствуют")
                        completion(.failure(NetworkError.noData))
                    }
                } else {
                    print("[dataTask]: NetworkError.httpStatusCode - Код ответа \(response.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
            }
        }
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[objectTask]: NetworkError.decodingError - \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[objectTask]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
