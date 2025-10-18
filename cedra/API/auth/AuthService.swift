//
//  AuthService.swift
//  Cedra
//
//  Created by Sebbe Mercier on 14/08/2025.
//

import Foundation

// MARK: - Wrappers tolérants
@propertyWrapper
struct StringOrInt: Decodable {
    var wrappedValue: String
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let s = try? c.decode(String.self) { wrappedValue = s; return }
        if let i = try? c.decode(Int.self)    { wrappedValue = String(i); return }
        throw DecodingError.typeMismatch(String.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Expected String or Int"))
    }
}

@propertyWrapper
struct StringOrIntOptional: Decodable {
    var wrappedValue: String?
    init(from decoder: Decoder) throws {
        guard let c = try? decoder.singleValueContainer() else { wrappedValue = nil; return }
        if let s = try? c.decode(String.self) { wrappedValue = s; return }
        if let i = try? c.decode(Int.self)    { wrappedValue = String(i); return }
        wrappedValue = nil
    }
}

// MARK: - Modèles de réponse
struct APIUser: Decodable {
    @StringOrInt var id: String
    let name: String?
    let email: String
    let role: String?
    @StringOrIntOptional var companyId: String?
    let companyName: String?
    let isCompanyAdmin: Bool?
}

/// ✅ Corrigé pour coller au backend (`error` et pas `message`)
struct MessageResponse: Decodable {
    let error: String
}

struct EmptyResponse: Decodable {}

// MARK: - Service d'authentification
final class AuthService {
    static let shared = AuthService()
    private init() {}

    // 👉 Ton backend Go tourne sur 8080
    private let baseURL = "http://192.168.1.200:8080/api/auth"

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Connexion
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        request(path: "/login",
                body: ["email": email, "password": password],
                expecting: LoginResponse.self,
                completion: completion)
    }

    func register(payload: [String: Any],
                  completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        request(path: "/register",
                body: payload,
                expecting: LoginResponse.self,
                completion: completion)
    }

    // MARK: - Connexion sociale
    func socialLogin(provider: String, token: String,
                     completion: @escaping (Result<LoginResponse, Error>) -> Void) {
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

            let status = http.statusCode
            let ctype = http.allHeaderFields["Content-Type"] as? String ?? "?"
            let size = data?.count ?? 0
            print("📡 \(req.httpMethod ?? "?") \(url.absoluteString) → \(status) | \(ctype) | \(size) bytes")

            guard let data = data, !data.isEmpty else {
                if T.self == EmptyResponse.self {
                    return finish(.success(EmptyResponse() as! T))
                }
                return finish(.failure(NSError(domain: "AuthService", code: -3,
                                               userInfo: [NSLocalizedDescriptionKey: "Réponse vide"])))
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📥 RAW:", raw)
            }

            guard (200...299).contains(status) else {
                // ✅ Ici on décode le message d'erreur custom { "error": "..." }
                if let apiError = try? self.decoder.decode(MessageResponse.self, from: data) {
                    let msg = apiError.error
                    return finish(.failure(NSError(domain: "AuthService", code: status,
                                                   userInfo: [NSLocalizedDescriptionKey: msg])))
                }
                return finish(.failure(NSError(domain: "AuthService", code: status,
                                               userInfo: [NSLocalizedDescriptionKey: "Erreur serveur \(status)"])))
            }

            do {
                let object = try self.decoder.decode(T.self, from: data)
                finish(.success(object))
            } catch {
                print("❌ Decode error:", error)
                finish(.failure(error))
            }
        }.resume()
    }
}

