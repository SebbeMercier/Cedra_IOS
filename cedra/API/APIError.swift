//
//  APIError.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/08/2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noHTTPResponse
    case badStatus(Int, String?)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:                 return "URL invalide."
        case .noHTTPResponse:             return "Réponse HTTP manquante."
        case .badStatus(let c, let msg):  return "Erreur serveur (\(c))" + (msg.flatMap { ": \($0)" } ?? "")
        case .decodingFailed:             return "Réponse illisible."
        }
    }
}
