//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 01.10.2024.
//
import UIKit
import WebKit

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidResponseFormat
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка URLRequest: \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("Некорректный формат ответа")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                if 200...299 ~= response.statusCode {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        print("Данные отсутствуют")
                        completion(.failure(NetworkError.urlSessionError))
                    }
                } else {
                    print("Ошибка сервера. Код ответа \(response.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
            }
        }
        
        return task
    }
}
