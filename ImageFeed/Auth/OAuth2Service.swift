//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 29.09.2024.
//
import UIKit
import WebKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let dataStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    
    // Добавляем новые свойства для отслеживания задач
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Проверяем, что мы на главном потоке
        assert(Thread.isMainThread)
        
        // Логика обработки повторных запросов
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = object(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Очищаем состояние задачи
                self.task = nil
                self.lastCode = nil
                
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var components = URLComponents(string: "https://unsplash.com/oauth/token")
        
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components?.url else {
            assertionFailure("Не удалось создать URL из URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}

// MARK: - Network Client
extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let token = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(token))
                } catch {
                    print("Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Сетевая ошибка: \(error)")
                completion(.failure(error))
            }
        }
    }
}
