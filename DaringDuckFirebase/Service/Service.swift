//
//  Service.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage

///
///
/// Photo işlemleri ::

/// uploadPhoto:  Fotoğrafı FireStrorage a yükler. -  Firestore da yeni post ekler(kullanıcı id  ve diğer parametreler ile) -  Yükleme yapan kullanıcının post dizisine yenisiini ekler.
/// Görsel boyutunu indirmede sorun çıkmaması için 1MB altına düşürür.
///
/// downloadPhotoToGallery : Firestoredan görsel datasını çeker ve çağırana iletir.
///

class Service {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    static let shared = Service()
    
    // MARK: -  Photo Functions
    
    // MARK: Upload Photo
    
    func uploadPhoto(image: UIImage, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard var imageData = image.jpegData(compressionQuality: 0.3) else {
            completion(.failure(ServiceError.imageDataConversion))
            return
        }
        // Veriyi 1 MB'dan küçük olana kadar kaliteyi düşür , Download 1mb ile sınırlı olduğu için
        var compressionQuality: CGFloat = 1.0
        while imageData.count > 1 * 1024 * 1024, compressionQuality > 0 {
            compressionQuality -= 0.1
            guard let newImageData = image.jpegData(compressionQuality: compressionQuality) else {
                completion(.failure(ServiceError.imageDataConversion))
                return
            }
            imageData = newImageData
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Save data to Storage with  unique ID based on user ID
        let storageRef = storage.reference().child("userPhotos/\(userId)/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                // Save the image URL and other details in Firestore
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let downloadURL = url {
                        let postId = UUID().uuidString
                        let data = [
                            "postId": postId as String,
                            "photoURL": downloadURL.absoluteString as String,
                            "postedByID": userId as String,
                            "timestamp": Timestamp(date: Date()) as Any,
                            "comments": [] as [[String: String]]
                        ]
                        self.db.collection("posts").document(postId).setData(data) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                // Add the post ID to the user's postIDs array
                                self.db.collection("users").document(userId).updateData(["postIDs": FieldValue.arrayUnion([postId])]) { error in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else {
                                        AuthService.shared.loadCurrentUser {_ in
                                            completion(.success(postId))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK:  Download Image to  Photo
    
    func downloadPhotoToGallery(withURL urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        // Fetch data from Storage using  URL
        let storageRef = storage.reference(forURL: urlString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
    }
    
    
    
    
    
    // Hata tipleri
    enum ServiceError: Error {
        case imageDataConversion
        case noPhotosFound
        case documentNotFound
        case invalidURL
    }
}
