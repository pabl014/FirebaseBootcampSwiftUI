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
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
    
//    func signInApple() async throws {
//        let helper = SignInAppleHelper()
//        let tokens = try await helper.signInWithAppleFlow()
//        let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
//    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
}
