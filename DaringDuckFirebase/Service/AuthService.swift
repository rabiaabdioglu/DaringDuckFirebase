//  AuthService.swift
//  TarzoneApp
//
//  Created by Rabia Abdioğlu on 19.05.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage


/// Auth::

/// userSession: Current user id
/// signInWithEmailAndPassword: Kullanıcı mail ve şifre ile oturum açar..
/// createUserWithEmailAndPassword: Yeni bir kullanıcı oluşturur.
/// signOut: Kullanıcı çıkış yapar.
/// sendPasswordResetEmail: Şifre sıfırlama maili  gönderir.
/// sendSignInLinkToEmail:  Mail onayı için .
/// isEmailVerified: Mail onaylı mı kontrolü.
///
///
/// Kullanıcı Verileri:
//
///uploadUserData: Yeni oluşturulan kullanıcının verilerini Firestore'a yükler.
///loadCurrentUser: Current user verilerini Firestore'dan çeker
///getSomeUser: Belirli bir kullanıcının verilerini  id si ile Firestore'dan çeker.
///
///
///Diğer Yardımcı Fonksiyonlar:
///isValidEmail:  Mail adresinin uygun olup olmadığını kontrol eder.
///
///

class AuthService {
    var userSession: String? {
        Auth.auth().currentUser?.uid
    }
    var userData: UserModel?
    
    
    static let shared = AuthService()
    
    
    // MARK: -  Auth  Functions
    
    // MARK: Sign Up Function
    func createUserWithEmailAndPassword(email: String, password: String, username: String, completion: @escaping (Error?) -> Void) {
        
        // Try to create a new user
        Auth.auth().createUser(withEmail: email, password: password) { [self] (result, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let uid = result?.user.uid else { return }
            uploadUserData(uid: uid, username: username, email: email)
            completion(nil)
        }
    }
    
    // MARK: Sign In Function
    
    func signInWithEmailAndPassword(withEmail: String, password: String, completion: @escaping (Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            if let error = error {
                print("Failed to log in user with error: \(error.localizedDescription)")
                return
            }
            // If login successful, set user session.
            print("User logged in successfully!")
            completion(nil)
        }
        
        loadCurrentUser { user in
            self.userData = user
        }
    }
    
    // MARK: Sign Out Function
    // Sign out the current user.
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userData = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: Reset Pass
    
    //sendPasswordResetEmail
    func sendPasswordResetEmail(email: String, completion: @escaping (Error?) -> Void) {
        //        //        // Check if a user with the provided email exists
        //        Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
        //            if let error = error {
        //                completion(error)
        //                return
        //            }
        //            //
        //            print(error?.localizedDescription)
        // User exists, send the password reset email
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(error)
                return
            }
            // Password reset email sent successfully
            completion(nil)
        }
        
    }
    
    // MARK: Email Link
    
    //    sendSignInLinkToEmail
    func sendSignInLinkToEmail(email: String, completion: @escaping (Error?) -> Void) {
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "daringduck-e386c.firebaseapp.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().currentUser?.sendEmailVerification{ error in
            if let error = error {
                print("Error sending sign-in link to email: \(error.localizedDescription)")
                return
            }
            completion(nil)
            print("Sign-in link sent to email successfully")
        }
    }
    
    func isCurrentUser(user: UserModel) -> Bool {
        if let currentUser = Auth.auth().currentUser {
            return user.id == currentUser.uid
        }
        return false
    }
    
    // MARK:  Email Validation
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    // Error messages for user information
    func isEmailVerified(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let user = Auth.auth().currentUser {
                if user.isEmailVerified {
                    print("User's email is verified.")
                    completion(true)
                } else {
                    print("User's email is not verified.")
                    completion(false)
                }
            } else {
                print("No user is currently signed in.")
                completion(false)
            }
        })
    }
    
    
    // MARK: - User Data Functions
    
    // MARK:  Upload User Data
    
    private func uploadUserData(uid: String, username: String, email: String)  {
        
        let user = UserModel(id: uid, name: username, email: email)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        Firestore.firestore().collection("users").document(uid).setData(encodedUser)
    }
    
    // MARK: Load User
    
    // Load user data from Firestore.
    func loadCurrentUser( completion: @escaping (UserModel?) -> Void) {
        guard let uid = self.userSession else {
            signOut()
            completion(nil)
            return
        }
        
        print(uid)
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else {
                print("Document data was empty.")
                completion(nil)
                return
            }
            do {
                let user = try Firestore.Decoder().decode(UserModel.self, from: data)
                self.userData = user
                completion(user)
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    // MARK: Get user detail (not current user)
    
    // Get User Info with id
    
    func getSomeUser(with uid : String, completion: @escaping (UserModel?) -> Void) {
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else {
                print("Document data was empty.")
                completion(nil)
                return
            }
            do {
                let user = try Firestore.Decoder().decode(UserModel.self, from: data)
                completion(user)
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    
}

