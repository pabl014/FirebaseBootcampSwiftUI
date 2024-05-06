//
//  SignInGoogleHelper.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 06/05/2024.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

// It has its own class, because if I had multiple viewModels in an app that were all using Google SignIn,
// I wouldn't have to rewrite this func signIn() for every screen
final class SignInGoogleHelper {
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        
        // needed to present info: <Appname> wants to use "google.com" to Sign In
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}
