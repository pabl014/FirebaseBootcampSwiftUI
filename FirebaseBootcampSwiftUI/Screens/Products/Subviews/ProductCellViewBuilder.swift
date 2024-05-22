//
//  ProductCellViewBuilder.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 22/05/2024.
//

import SwiftUI

struct ProductCellViewBuilder: View {
    
    let productId: String // 1. When we initialize ProductCellViewBuilder, we'll only have productId
    @State private var product: Product? = nil // 3. Fetching this product
    
    var body: some View {
        ZStack {
            if let product {
                ProductCellView(product: product) // 2. This screen appears 4. Then it's injected there
            }
        }
        //.background(.red)
        .task {
            self.product = try? await ProductsManager.shared.getProduct(productId: productId) // 3. Fetching this product
        }
    }
}

#Preview {
    ProductCellViewBuilder(productId: "1")
}
