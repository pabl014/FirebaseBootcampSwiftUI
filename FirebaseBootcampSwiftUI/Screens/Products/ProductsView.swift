//
//  ProductsView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 12/05/2024.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProductsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    @Published var selectedSort: SortOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    private var lastDocument: DocumentSnapshot? = nil // in a larger app we might want to create some sort of local type to hold a DocumentSnapshot, so that if you're using this on multiple screens, you don't have to import Firebase every time. You can make a struct that is like "MySnapshotContainer" or "MyQueryHolder" and then put the document snapshot inside so that when you initialize the struct you import Firestore and you have reference
    
//    func getAllProducts() async throws {
//        self.products = try await ProductsManager.shared.getAllProducts()
//    }
    
    enum SortOption: String, CaseIterable {
        case noOption = "No Option"
        case priceHigh = "Highest Price"
        case priceLow = "Lowest Price"
        
        var priceDescending: Bool? {
            switch self {
            case .noOption: return nil
            case .priceHigh: return true
            case .priceLow: return false
            }
        }
    }
    
    func sortSelected(option: SortOption) async throws {
        self.selectedSort = option
        self.getProducts()
        
//        switch option {
//        case .noFilter:
//            self.products = try await ProductsManager.shared.getAllProducts()
//        case .priceHigh:
//            // 1. query on the db and get the items
//            // 2. update the ui
//            // 3. set the filter to price high
//            self.products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: true)
//        case.priceLow:
//            self.products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: false)
//        }
        
    }
    
    
    // in real app all categories should be stored in your backend somewhere that you can just download
    enum CategoryOption: String, CaseIterable {
        case noCategory = "No Category"
        case smartphones
        case laptops
        case fragrances
        
        var categoryKey: String? {
            if self == .noCategory {
                return nil
            } else {
                return self.rawValue
            }
        }
    }
    
    func categorySelected(option: CategoryOption) async throws {
        self.selectedCategory = option
        self.getProducts()
//        switch option {
//        case .noCategory:
//            self.products = try await ProductsManager.shared.getAllProducts()
//        case .smartphones, .laptops, .fragrances:
//            self.products = try await ProductsManager.shared.getAllProductsForCategory(category: option.rawValue)
//        }
        
    }
    
    
    func getProducts() {
        Task {
            self.products = try await ProductsManager.shared.getAllProducts(priceDescending: selectedSort?.priceDescending, forCategory: selectedCategory?.categoryKey)
        }
    }
    
    
//    func getProductsByRating() {
//        Task {
// //            let newProducts = try await ProductsManager.shared.getProductsByRating(count: 3, lastRating: self.products.last?.rating)
// //            self.products.append(contentsOf: newProducts)
//            let (newProducts, lastDocument) = try await ProductsManager.shared.getProductsByRating(count: 3, lastDocument: lastDocument)
//            
//            self.products.append(contentsOf: newProducts)
//            self.lastDocument = lastDocument
//        }
//    }
    
}


struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    
    var body: some View {
        List {
//            Button("FETCH MORE OBJECTS") {
//                viewModel.getProductsByRating()
//            }
            
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
            }
        }
        .navigationTitle("Products")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Filter: \(viewModel.selectedSort?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.sortSelected(option: option)
                            }
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.categorySelected(option: option)
                            }
                        }
                    }
                }
            }
        })
        .onAppear {
            viewModel.getProducts()
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
