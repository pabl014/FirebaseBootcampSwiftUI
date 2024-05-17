//
//  ProductsManager.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 12/05/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsManager {
    static let shared = ProductsManager()
    private init() { }
    
    private let productsCollection = Firestore.firestore().collection("products")
    
    private func productDocument(productId: String) -> DocumentReference {
        productsCollection.document(productId)
    }
    
    
    func uploadProduct(product: Product) async throws {
        try productDocument(productId: String(product.id)).setData(from: product, merge: false)
    }
    
    
    func getProduct(productId: String) async throws -> Product {
        try await productDocument(productId: productId).getDocument(as: Product.self)
    }
    
    
//    func getAllProducts() async throws -> [Product] {
//        let snapshot = try await productsCollection.getDocuments() // there is no func like getDocuments(as: ), try await userDocument(userId: userId).getDocument(as: DBUser.self), so we need to make a snapshot
//        
//        var products: [Product] = []
//        
//        // looping through the documents and convert them to the product individually
//        for document in snapshot.documents {
//            let product = try document.data(as: Product.self)
//            products.append(product)
//        }
//        
//        return products
//    }
    
    private func getAllProducts() async throws -> [Product] {
        try await productsCollection.getDocuments(as: Product.self)
    }
    
    
    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
        try await productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            .getDocuments(as: Product.self)
    }
    
    
    private func getAllProductsForCategory(category: String) async throws -> [Product] {
        try await productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .getDocuments(as: Product.self)
    }
    
    
    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
        try await productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            .getDocuments(as: Product.self)
    }
    
    // this func will be called from app
    func getAllProducts(priceDescending descending: Bool?, forCategory category: String?) async throws -> [Product] {
        if let descending, let category {
            return try await getAllProductsByPriceAndCategory(descending: descending, category: category)
        } else if let descending {
            return try await getAllProductsSortedByPrice(descending: descending)
        } else if let category {
            return try await getAllProductsForCategory(category: category)
        }
        return try await getAllProducts()
    }
}

extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
    
    
//    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
//        
//        let snapshot = try await self.getDocuments()
//        
//        var products: [T] = []
//        
//        for document in snapshot.documents {
//            let product = try document.data(as: T.self)
//            products.append(product)
//        }
//        
//        return products
//    }
}
