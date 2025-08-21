//
//  AuthService.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import Foundation

// MARK: - Modèles de réponse
struct APIUser: Codable {
    let id: Int
    let name: String
    let email: String
    let isAdmin: Bool
    let companyId: Int?
    let companyName: String?
    let isCompanyAdmin: Bool? // ← optionnel ici
}


struct LoginResponse: Codable {
    let token: String
    let user: APIUser
}

struct MessageResponse: Codable {
    let message: String
}

struct EmptyResponse: Codable {} // ✅ Réponse vide tolérée

// MARK: - Service d'authentification
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let baseURL = "http://192.168.0.200:5000/api/auth"

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    // MARK: - Connexion
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        request(path: "/login",
                body: ["email": email, "password": password],
                expecting: LoginResponse.self,
                completion: completion)
    }

    // MARK: - Inscription
    func register(payload: [String: Any],
                  completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        request(path: "/register",
                body: payload,
                expecting: LoginResponse.self,
                completion: completion)
    }

    // MARK: - Connexion via réseau social
    func socialLogin(provider: String, token: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        request(path: "/social",
                body: ["provider": provider, "token": token],
                expecting: LoginResponse.self,
                completion: completion)
    }

    // MARK: - Méthode générique POST
    private func request<T: Decodable>(path: String,
                                       body: [String: Any],
                                       expecting: T.Type,
                                       completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + path) else {
            return completion(.failure(NSError(domain: "AuthService", code: -1,
                                               userInfo: [NSLocalizedDescriptionKey: "URL invalide"])))
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        session.dataTask(with: req) { data, response, error in
            func finish(_ result: Result<T, Error>) {
                DispatchQueue.main.async { completion(result) }
            }

            if let error = error {
                return finish(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                return finish(.failure(NSError(domain: "AuthService", code: -2,
                                               userInfo: [NSLocalizedDescriptionKey: "Pas de réponse HTTP"])))
            }

            guard let data = data, !data.isEmpty else {
                if T.self == EmptyResponse.self {
                    return finish(.success(EmptyResponse() as! T))
                } else {
                    return finish(.failure(NSError(domain: "AuthService", code: -3,
                                                   userInfo: [NSLocalizedDescriptionKey: "Réponse vide"])))
                }
            }

            guard (200...299).contains(http.statusCode) else {
                if let apiError = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    return finish(.failure(NSError(domain: "AuthService", code: http.statusCode,
                                                   userInfo: [NSLocalizedDescriptionKey: apiError.message])))
                }
                return finish(.failure(NSError(domain: "AuthService", code: http.statusCode,
                                               userInfo: [NSLocalizedDescriptionKey: "Erreur serveur \(http.statusCode)"])))
            }

            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                finish(.success(object))
            } catch {
                finish(.failure(error))
            }
        }.resume()
    }
}
