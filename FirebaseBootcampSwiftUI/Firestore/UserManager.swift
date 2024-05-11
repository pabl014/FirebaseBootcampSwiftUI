//
//  UserManager.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 08/05/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Codable = Encodable + Decodable
struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false 
    }
    
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
    }
    
    
//    func togglePremiumStatus() -> DBUser {
//        let currentValue = isPremium ?? false
//        return DBUser(
//            userId: userId,
//            isAnonymous: isAnonymous,
//            email: email,
//            photoUrl: photoUrl,
//            dateCreated: dateCreated,
//            isPremium: !currentValue
//        )
//    }
    
    
//    mutating func togglePremiumStatus() {
//        let currentValue = isPremium ?? false
//        isPremium = !currentValue
//    }
    
    // case, when data in database is not snake_cased and camelCased
    // we need to create custom encoder or decoder for that object:
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "user_isPremium"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    // encoder for snake case
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
//    
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String: Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//        ]
//        if let email = auth.email { // because email is optional
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photourl {
//            userData["photoUrl"] = photoUrl
//        }
//        
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//        
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else { // .data() converts the snapshot to the dictionary, which looks like var userData: [String: Any] = [ ... ] from func createNewUser
//            throw URLError(.badServerResponse)
//        }
//        
//        // data is of type [String : Any], so we must cast properties as proper values
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//        
//        return DBUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
//    func updateUserPremiumStatus(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: true, encoder: encoder) // merge: true -> merge this data with the existing data
//    }
    
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        try await userDocument(userId: userId).updateData(data)
    }
}
