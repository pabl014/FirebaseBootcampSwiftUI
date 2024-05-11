//
//  AuthenticationManager.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 05/05/2024.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) { // User -> comes from FirebaseSDK
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}


enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
}

final class AuthenticationManager {
    
    // making it singleton
    static let shared = AuthenticationManager()
    private init() { }
    
    //  !!! no async here -> it's going to check for the authenticated user locally, it's not reaching out to the server
    //  INCREDIBLY IMPORTANT, because if our app is loading for the first time and checking if a user is authenticated, we want to check that basically synchronously before the whole app loads
    //  If it was async, we might have to add stuff like loading screend into our app or we might get the wrong value before the server returns
    //  Once we authenticate a user it's being saved in the SDK locally and then we can just get the value from the local SDK
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        // This is an array, because every user has the ability to sign in with more than one provider.
        // You can have your users sign in with email and they can also connect their gmail account, so that's why one user can have many providers
        for provider in providerData {
            //print(provider.providerID)
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                // Failurtes in swift:
                // fatalError() -> it's better not to use it, because it crashes users
                //preconditionFailure()
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        print(providers)
        return providers
    }
    
   
    // synchronous (not async) -> it's going to sign out locally. We don;t need to ping the server. It happens immediately.
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
    }
    
}


//MARK: - SIGN IN EMAIL & PASSWORD
extension AuthenticationManager {

    @discardableResult // we know there is a result ( a return value ), but we might not always use it so it's ok if we want to discard it
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResultModel(user: authDataResult.user)
        return result
    }
    
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    func resetPassword(email: String) async throws {
       try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // updating the authenticated users' password
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            // error handling there
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    

    // updating the authenticated users' email
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            // error handling there
            throw URLError(.badServerResponse)
        }
        
        // try await user.updateEmail(to: email) : DEPRECATED
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}


//MARK: - SIGN IN SSO
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}


//MARK: - SIGN IN ANONYMOUS
extension AuthenticationManager {
    
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password) // similar to func signIn()
        return try await linkCredential(credential: credential)
    }
    
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken) // similar to func signInWithGoogle()
        return try await linkCredential(credential: credential)
    }
    
    
    
//    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
//        let credential =
//        return try await linkCredential(credential: credential)
//    }
//    
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
