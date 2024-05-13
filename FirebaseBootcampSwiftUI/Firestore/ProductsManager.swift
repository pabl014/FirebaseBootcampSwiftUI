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
    
    
    func getAllProducts() async throws -> [Product] {
        let snapshot = try await productsCollection.getDocuments() // there is no func like getDocuments(as: ), try await userDocument(userId: userId).getDocument(as: DBUser.self), so we need to make a snapshot
        
        var products: [Product] = []
        
        // looping through the documents and convert them to the product individually
        for document in snapshot.documents {
            let product = try document.data(as: Product.self)
            products.append(product)
        }
        
        return products
    }
    
}
