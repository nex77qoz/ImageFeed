//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 29.09.2024.
//
import UIKit
import WebKit
import ProgressHUD

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }

    
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
        
        print("Сформирован URLRequest: \(request)")
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Не удалось создать URLRequest")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
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
                    print("Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Сетевая ошибка: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

}
