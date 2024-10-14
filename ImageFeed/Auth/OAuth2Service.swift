//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 29.09.2024.
//
import UIKit
import WebKit

final class OAuth2Service {
    static let shared = OAuth2Service()

    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var components = URLComponents(string: "https://unsplash.com/oauth/token")
        
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.AccessKey),
            URLQueryItem(name: "client_secret", value: Constants.SecretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components?.url else {
            fatalError("Не получилось собрать URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print(request) // Для проверки
        
        return request
    }
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let token = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        OAuth2TokenStorage.shared.token = token.accessToken
                        completion(.success(token.accessToken))
                    } catch {
                        completion(.failure((error)))
                        print("Decoding error: \(error)")
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Network error: \(error)")
            }
        }
        
        task.resume()
    }
}
