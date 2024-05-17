//
//  ProductsView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 12/05/2024.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    @Published var selectedSort: SortOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    
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
    
}


struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    
    var body: some View {
        List {
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
