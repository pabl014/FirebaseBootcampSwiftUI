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
    
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResultModel(user: authDataResult.user)
        return result
    }
    
}
