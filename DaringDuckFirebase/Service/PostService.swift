//
//  PostService.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 22.03.2024.
//

import Foundation
import Foundation
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage
///
/// Post  Service ::

/// get Post:   Varolan postun verilerini id ye göre çeker. PostModel döndürür.
/// dataToPostModel :  gelen datayı Postmodele çevirme işlemini yapar. Post Modeli döndürür
///
/// getUserPosts : Kullanıcıya ait tüm postları çeker. Kullanıcının post idleri olan dizisi burada yardım eder..
///
/// getAllPosts: Firestore'daki tüm gönderileri getirir.
///
/// leaveComment: Belirli bir kullanıcı tarafından belirli bir gönderiye yorum bırakır.
///
///

class PostService {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    static let shared = PostService()
    
    
    // Get post detail with postID and retrun PostModel
    func getPost(postID: String, completion: @escaping (PostModel?) -> Void) {
        Firestore.firestore().collection("posts").document(postID).getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching post data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let postData = snapshot?.data() else {
                print("Document data was empty.")
                completion(nil)
                return
            }
            let id = snapshot?.documentID ?? ""
            let postModel = self.dataToPostModel(postData: postData, id: id)
            completion(postModel)
        }
    }
    
    // Convert data to PostModel
    func dataToPostModel(postData: [String: Any], id: String) -> PostModel {
        let imageURL = postData["photoURL"] as? String ?? ""
        let postedByID = postData["postedByID"] as? String ?? ""
        let commentsData = postData["comments"] as? [[String: Any]] ?? []
        var comments: [Comment] = []
        for commentData in commentsData {
            if let commenterID = commentData["commenterID"] as? String,
               let commentText = commentData["commentText"] as? String {
                let comment = Comment(commenterID: commenterID, commentText: commentText)
                comments.append(comment)
            }
        }
        let date = postData["timestamp"] as? String ?? ""
        let postModel = PostModel(id: id, photoURL: imageURL, postedByID: postedByID, comments: comments, timestamp: date)
        
        return postModel
    }
    
    // MARK: - Get User Posts
    // Get users all posts in the user's postID array
    func getUserPosts(for user: UserModel, completion: @escaping ([PostModel], Error?) -> Void) {
        let postIDs = user.postIDs
        
        var userPosts: [PostModel] = []
        
        let dispatchGroup = DispatchGroup()
        
        for postID in postIDs {
            dispatchGroup.enter()
            self.db.collection("posts").document(postID).getDocument { (postDocument, postError) in
                defer {
                    dispatchGroup.leave()
                }
                if let postError = postError {
                    print("Error getting post document: \(postError)")
                    return
                }
                guard let postDocument = postDocument,
                      let postData = postDocument.data() else {
                    print("Post document does not exist or does not contain data")
                    return
                }
                let id = postDocument.documentID
                let postModel = self.dataToPostModel(postData: postData, id: id)
                userPosts.append(postModel)
            }
        }
        
        // Notify  completion  when all posts are gfetch
        dispatchGroup.notify(queue: .main) {
            completion(userPosts, nil)
        }
        
    }
    
    
    // MARK: - Get  ALL User Photos
    
    // get all post
    func getAllPosts(completion: @escaping ([PostModel], Error?) -> Void) {
        
        var allPosts: [PostModel] = []
        
        
        self.db.collection("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion([], error)
                return
            }
            let dispatchGroup = DispatchGroup()
            for document in querySnapshot!.documents {
                dispatchGroup.enter()
                let postData = document.data()
                let id = document.documentID
                let postModel = self.dataToPostModel(postData: postData, id: id)
                allPosts.append(postModel)
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main) {
                completion(allPosts, nil)
            }
        }
    }
    
    // Comment function
    func leaveComment(currentUserID: String, postID: String, commentText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let commentData = [
            "commenterID": currentUserID,
            "commentText": commentText
        ]
        
        db.collection("posts").document(postID).updateData([
            "comments": FieldValue.arrayUnion([commentData])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
}
