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
    
//    private func getAllProducts() async throws -> [Product] {
//        try await productsCollection
////            .limit(to: 5)
//            .getDocuments(as: Product.self)
//    }
//    
//    
//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
////            .limit(toLast: 3)
//            .getDocuments(as: Product.self)
//    }
//    
//    
//    private func getAllProductsForCategory(category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .getDocuments(as: Product.self)
//    }
//    
//    
//    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
    
    private func getAllProductsQuery() -> Query {
        productsCollection
    }
    
    
    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
        productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    
    private func getAllProductsForCategoryQuery(category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    
    private func getAllProductsByPriceAndCategoryQuery(descending: Bool, category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    // this func will be called from app
    func getAllProducts(priceDescending descending: Bool?, forCategory category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Product], lastDocument: DocumentSnapshot?) {
        
        var query: Query = getAllProductsQuery()
        
        if let descending, let category {
            query = getAllProductsByPriceAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category {
            query = getAllProductsForCategoryQuery(category: category)
        }
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Product.self)
        
//        if let lastDocument {
//            return try await query
//                .limit(to: count)
//                .start(afterDocument: lastDocument)
//                .getDocumentsWithSnapshot(as: Product.self)
//        } else {
//            return try await query
//                .limit(to: count)
//                .getDocumentsWithSnapshot(as: Product.self)
//        }
        
    }
    
    
//    func getProductsByRating(count: Int, lastRating: Double?) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//            .limit(to: count)
////            .start(at: [4.5]) // anything above 4.5 rating is excluded
//            .start(after: [lastRating ?? 9999999])
//            .getDocuments(as: Product.self)
//    }
    
    
//    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Product], lastDocument: DocumentSnapshot?) {
//        if let lastDocument {
//            return try await productsCollection
//                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//                .limit(to: count)
//                .start(afterDocument: lastDocument )
//                .getDocumentsWithSnapshot(as: Product.self)
//        } else {
//            return try await productsCollection
//                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
//                .limit(to: count)
//                .getDocumentsWithSnapshot(as: Product.self)
//        }
//    }
    
    
    func getAllProductsCount() async throws -> Int {
        try await productsCollection.aggregateCount()
    }
}

extension Query {
    
//    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
//        
//        let snapshot = try await self.getDocuments()
//        
//        return try snapshot.documents.map({ document in
//            try document.data(as: T.self)
//        })
//    }
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).products
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
    
    // will get all of the documents, but will also give back the last document snapshot
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        
        let snapshot = try await self.getDocuments()
        
        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (products, snapshot.documents.last)
    }
    
//        .start(afterDocument: lastDocument)
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else {
            return self
        }
        
        return self.start(afterDocument: lastDocument)
    }
    
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
}
