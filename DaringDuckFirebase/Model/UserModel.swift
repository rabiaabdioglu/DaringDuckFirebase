//
//  UserModel.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//

import Foundation

struct UserModel: Identifiable, Decodable, Encodable {
    
    let id: String
    let name: String
    let email: String
    var postIDs: [String]

    init(id: String, name: String, email: String, postIDs: [String] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.postIDs = postIDs
    }
}
