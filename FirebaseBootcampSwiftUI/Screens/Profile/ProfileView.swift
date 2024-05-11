//
//  ProfileView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 08/05/2024.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    // private(set) -> mozliwy jest odczyt i zmiana wartosci wewnatrz obecnej klasy, ale poza nia mozliwy jest tylko odczyt
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        //user.togglePremiumStatus()
        //let updatedUser = user.togglePremiumStatus() // taking the current struct and then, creating and returning a new struct
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
