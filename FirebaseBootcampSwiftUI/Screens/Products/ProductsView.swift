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
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    
    func getAllProducts() async throws {
        self.products = try await ProductsManager.shared.getAllProducts()
    }
    
    
    enum FilterOption: String, CaseIterable {
        case noFilter = "No Filter"
        case priceHigh = "Highest Price"
        case priceLow = "Lowest Price"
    }
    
    func filterSelected(option: FilterOption) async throws {
        switch option {
        case .noFilter:
            self.products = try await ProductsManager.shared.getAllProducts()
        case .priceHigh:
            // 1. query on the db and get the items
            // 2. update the ui
            // 3. set the filter to price high
            self.products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: true)
        case.priceLow:
            self.products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: false)
        }
        
        self.selectedFilter = option
    }
    
    
    // in real app all categories should be stored in your backend somewhere that you can just download
    enum CategoryOption: String, CaseIterable {
        case noCategory = "No Category"
        case smartphones
        case laptops
        case fragrances
    }
    
    func categorySelected(option: CategoryOption) async throws {
        switch option {
        case .noCategory:
            self.products = try await ProductsManager.shared.getAllProducts()
        case .smartphones, .laptops, .fragrances:
            self.products = try await ProductsManager.shared.getAllProductsForCategory(category: option.rawValue)
        }
        
        self.selectedCategory = option
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
                Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.filterSelected(option: option)
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
        .task {
            try? await viewModel.getAllProducts()
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
