//
//  SignInEmailViewModel.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 08/05/2024.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            // validation code here
            print("No email or password found")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult) // make new user
        try await UserManager.shared.createNewUser(user: user) // push him to the database
    }
    
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            // validation code here
            print("No email or password found")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
