//
//  Productservice.swift
//  Cedra
//
//  Created by Sebbe Mercier on 16/08/2025.
//

import Foundation

class ProductService {
    static let shared = ProductService()

    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        guard let url = URL(string: "http://192.168.0.200:5000/api/products/search?q=") else {
            completion(.failure(NSError(domain: "URL invalide", code: 0)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Aucune donnée", code: 0)))
                return
            }

            // ✅ Ajout du print JSON ici
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 JSON reçu :\n\(jsonString)")
            }

            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                completion(.success(products))
            } catch {
                print("❌ Erreur de décode :", error.localizedDescription)
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
