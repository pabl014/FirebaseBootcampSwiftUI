//
//  ProductsView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 12/05/2024.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    
    
    func downloadProductsAndUploadToFirebase() {
        // https://dummyjson.com/products
        guard let url = URL(string: "https://dummyjson.com/products") else { return }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                let products = try JSONDecoder().decode(ProductArray.self, from: data)
                let productsArray = products.products
                
                for product in productsArray {
                    try? await ProductsManager.shared.uploadProduct(product: product)
                }
                
                print("SUCCESS")
                print(products.products.count)
            } catch {
                print(error)
            }
        }
    }
}

struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        ZStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .navigationTitle("Products")
        .onAppear {
            viewModel.downloadProductsAndUploadToFirebase()
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
