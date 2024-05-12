//
//  Product.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 12/05/2024.
//

import Foundation

struct ProductArray: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

struct Product: Identifiable, Codable {
    let id: Int
    let title: String?
    let description: String?
    let price: Int?
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let brand, category: String?
    let thumbnail: String?
    let images: [String]?
}

//MARK: - Download products and upload to firebase (from ProductsViewModel, then in view called with .onAppear { })
//    func downloadProductsAndUploadToFirebase() {
//        // https://dummyjson.com/products
//        guard let url = URL(string: "https://dummyjson.com/products") else { return }
//
//        Task {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                    throw URLError(.badServerResponse)
//                }
//                let products = try JSONDecoder().decode(ProductArray.self, from: data)
//                let productsArray = products.products
//
//                for product in productsArray {
//                    try? await ProductsManager.shared.uploadProduct(product: product)
//                }
//
//                print("SUCCESS")
//                print(products.products.count)
//            } catch {
//                print(error)
//            }
//        }
//    }
