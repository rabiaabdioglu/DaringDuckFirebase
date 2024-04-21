//
//  TabbarViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAuth

class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private var user: UserModel?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // load user and check email verify
        AuthService.shared.loadCurrentUser{ user in
            self.user = user
            
            AuthService.shared.isEmailVerified { isVerified in
                if isVerified {
                    DispatchQueue.main.async {
                        self.setupViewControllers()
                    }
                } else {
                    DispatchQueue.main.async {
                        let emailVerifyVc = EmailVerifyViewController(user: self.user)
                        emailVerifyVc.modalPresentationStyle = .fullScreen
                        self.present(emailVerifyVc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabBar.alpha = 0.9
        tabBar.backgroundColor = UIColor.styledWhite
        tabBar.layer.cornerRadius = 20
        
        // Kullanıcı giriş yapmış mı kontrol et
        if let currentUser = Auth.auth().currentUser {
//            print("User already logged in")
            
        } else {
//            print("No user logged in")
            DispatchQueue.main.async {
                let loginViewController = SignInViewController()
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
        
        self.delegate = self
    }
    
    // Tab View UI 
    private func setupViewControllers() {
        let homeViewController = HomePageViewController(user: self.user)
        let uploadPhotoViewController = PhotoUploadViewController(user: self.user)
        let profileViewController = ProfileViewController(user: self.user)
        
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        uploadPhotoViewController.tabBarItem = UITabBarItem(title: "New", image: UIImage(systemName: "photo.badge.plus"), selectedImage: UIImage(systemName: "photo.badge.checkmark"))
        profileViewController.tabBarItem = UITabBarItem(title: "Events", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        let viewControllers = [homeViewController, uploadPhotoViewController, profileViewController]
        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0) }
    }
}
