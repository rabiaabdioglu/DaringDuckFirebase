//
//  PhotoUploadViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//

import Foundation
import SnapKit
import UIKit
import FirebaseFirestore

class PhotoUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var user = AuthService.shared.userData
    
    // MARK: - UI Components
    
    var imageStackView = CustomImageStackView(image: UIImage(named: "animalPhoto")!)
    var warningMessage = CustomWarningLabel(text: "", color: UIColor.styledErrorRed)
    let uploadPhotoButton = CustomButton(butonName: "Upload Photo", backgroundColor: .white, titleColor: UIColor.styledGreen, isShadow: true)
    let selectPhotoButton = CustomButton(butonName: "Select Photo", backgroundColor: UIColor.styledGreen , titleColor: .white , isShadow: true)
    let progressView = CustomProgressStackView()
    
    var selectedImage = UIImage()
    init(user: UserModel?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Upload Photo"
        setupButtons()
    }
    override func viewDidAppear(_ animated: Bool) {
        warningMessage.text = ""
        
        
    }
    
    // MARK: Setup
    
    func setupButtons() {
        
        
        // Image Stack
        view.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(view.safeAreaLayoutGuide.snp.width).multipliedBy(0.8)
            make.centerY.equalToSuperview().offset(-50)
        }
        
        
        // Select Photo from gallery Button
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageStackView.snp.bottom).offset(50)
            make.width.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
        
        // Upload Button
        uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoButtonTapped), for: .touchUpInside)
        uploadPhotoButton.isHidden = true
        
        view.addSubview(uploadPhotoButton)
        uploadPhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(selectPhotoButton.snp.bottom).offset(30)
            make.width.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
        
        // Warning Message Label
        warningMessage.font = UIFont.styledHeavyFont(size: 15)
        view.addSubview(warningMessage)
        warningMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(selectPhotoButton.snp.top).offset(-10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(20)
        }
        
        // Progress View Stack
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
        progressView.isHidden = true
        view.bringSubviewToFront(progressView)
        
    }
    
    // MARK: - FUNCTIONS

    
    
    // MARK: Button functions
    
    @objc func selectPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK:  Upload Photo  Firebase
    
    @objc func uploadPhotoButtonTapped() {
        progressView.isHidden = false
        uploadPhotoButton.isEnabled = false
        warningMessage.text = "Saving Image..."
        warningMessage.textColor = UIColor.systemGreen
        
        guard let selectedImage = imageStackView.imageView.image else {
            print("No image selected")
            return
        }
        
        guard let userId = user?.id else {
            print("User not found")
            return
        }
        // Service call func
        Service.shared.uploadPhoto(image: selectedImage, userId: userId) { [ self] result in
            switch result {
            case .failure(let error):
                warningMessage.text = "Error uploading photo."
            case .success(let postID):
                warningMessage.text = "Photo uploaded successfully."
                warningMessage.textColor = UIColor.systemGreen
                imageStackView.imageView.image = UIImage(named: "animalPhoto")
                progressView.isHidden = true
                uploadPhotoButton.isEnabled = true
                uploadPhotoButton.isHidden = true
                showDetailVC(postID: postID)
            }
        }
    }
    
    
    // MARK:  Detail
    
    // Go detail VC
    func showDetailVC(postID : String){
        guard let selectedImage = imageStackView.imageView.image else {
            print("No image selected")
            return
        }
        PostService.shared.getPost(postID: postID) { [self] post in
            let detailVC = PhotoDetailViewController(post: post!, user: user!)
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        
        
    }
    
    // MARK: Image Picker setup
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageStackView.imageView.image = selectedImage
            self.selectedImage = selectedImage
            // post notification
            NotificationCenter.default.post(name: Notification.Name("PhotoSelected"), object: imageStackView)
            uploadPhotoButton.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
