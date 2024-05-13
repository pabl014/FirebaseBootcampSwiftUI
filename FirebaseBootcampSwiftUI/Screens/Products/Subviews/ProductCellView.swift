//
//  ProductCellView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 13/05/2024.
//

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                ProgressView()
            }
            .frame(width: 75, height: 75)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title ?? "n/a")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Price: $" + String(product.price ?? 0))
                    .foregroundStyle(.secondary)
                Text("Rating: " + String(product.rating ?? 0) + " / 5")
                    .foregroundStyle(.secondary)
                Text("Category: " + (product.category ?? "n/a"))
                    .foregroundStyle(.secondary)
                Text("Brand: " + (product.brand ?? "n/a"))
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
        }
    }
}

#Preview {
    ProductCellView(
        product: Product(
            id: 1,
            title: "test",
            description: "test",
            price: 67,
            discountPercentage: 5,
            rating: 4.67,
            stock: 8,
            brand: "abibas",
            category: "shoes",
            thumbnail: "dab",
            images: []
        )
    )
}
