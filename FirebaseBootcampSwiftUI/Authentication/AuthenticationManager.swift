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
    let photourl: String?
    
    init(user: User) { // User -> comes from FirebaseSDK
        self.uid = user.uid
        self.email = user.email
        self.photourl = user.photoURL?.absoluteString
    }
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
    
    @discardableResult // we know there is a result ( a return value ), but we might not always use it so it's ok if we want to discard it
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResultModel(user: authDataResult.user)
        return result
    }
    
    // synchronous (not async) -> it's going to sign out locally. We don;t need to ping the server. It happens immediately.
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
}
