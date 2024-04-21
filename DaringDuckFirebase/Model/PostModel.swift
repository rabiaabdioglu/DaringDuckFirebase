//
//  Post.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 20.03.2024.
//

import Foundation

struct PostModel: Identifiable {
    let id: String
    let photoURL: String
    let postedByID: String
    var comments: [Comment] 
    let timestamp: String
    
}

struct Comment {
    let commenterID: String
    let commentText: String
}
