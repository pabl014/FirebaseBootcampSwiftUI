//
//  FavoritesView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 22/05/2024.
//

import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    // we can also have a struct that have userFavoriteProduct ID and product ID instead of tuple
    // @Published private(set) var products: [(userFavoriteProduct: UserFavoriteProduct, product: Product)] = []
    
    @Published private(set) var userFavoriteProducts: [UserFavoriteProduct] = []
    
    func addListenerForFavorites() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        UserManager.shared.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid) { [weak self] products in
            self?.userFavoriteProducts = products
        }
    }
    
    func getAllFavorites() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // getting the authenticated user
            // in an actual app it's not going to be good to do all of authDataResult fetch requests all of the time
            // instead it's better to inject the current userId into the viewModel init or into the struct of the view init or userDefault
            // that just holds the userId, so we don't have to make authDataResult request every single viewModel
            self.userFavoriteProducts = try await UserManager.shared.getAllUserFavoriteProducts(userId: authDataResult.uid)
            
//            var localArray: [(userFavoriteProduct: UserFavoriteProduct, product: Product)] = []
//            for userFavoritedProduct in userFavoritedProducts {
//                if let product = try? await ProductsManager.shared.getProduct(productId: String(userFavoritedProduct.productId)) {
//                    localArray.append((userFavoritedProduct, product))
//                }
//            }
//            
//            self.products = localArray
        }
    }
    
    
    func removeFromFavorites(favoriteProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // getting the authenticated user
            try? await UserManager.shared.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favoriteProductId)
            
            getAllFavorites()
        }
    }
}


struct FavoritesView: View {
    
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var didAppear: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.userFavoriteProducts, id: \.id.self) { item in // \.id.self => id of an object that we're looping on
                ProductCellViewBuilder(productId: String(item.productId))
                    .contextMenu {
//                        Button("Remove from favorites") {
//                            viewModel.removeFromFavorites(favoriteProductId: item.userFavoriteProduct.id)
//                        }
//                        
                        Button(role: .destructive) {
                            viewModel.removeFromFavorites(favoriteProductId: item.id)
                        } label: {
                            Label("Remove from favorites", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
//            viewModel.getAllFavorites()
            if !didAppear {
                viewModel.addListenerForFavorites()
                didAppear = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
