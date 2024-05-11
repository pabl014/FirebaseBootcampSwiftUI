//
//  AuthenticationViewModel.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 08/05/2024.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    // Pass the presenting view controller and client ID for your app to the signIn method of the Google Sign-In provider
    // and create a Firebase Authentication credential from the resulting Google auth token:
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult) // make new user
        try await UserManager.shared.createNewUser(user: user) // push him to the database
    }
    
//    func signInApple() async throws {
//        let helper = SignInAppleHelper()
//        let tokens = try await helper.signInWithAppleFlow()
//        let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
//        let user = DBUser(auth: authDataResult) // make new user
//        try await UserManager.shared.createNewUser(user: user) // push him to the database
//    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authDataResult) // make new user
        try await UserManager.shared.createNewUser(user: user) // push him to the database
        // try await UserManager.shared.createNewUser(auth: authDataResult)
    }
}
