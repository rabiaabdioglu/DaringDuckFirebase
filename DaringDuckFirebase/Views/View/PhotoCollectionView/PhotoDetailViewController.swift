//
//  PhotoDetailViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//

import Foundation
import UIKit
import Photos
class PhotoDetailViewController: UIViewController {
    
    var imageUrl : String?
    var isCurrentUser :  Bool?
    var user :  UserModel
    var post: PostModel
    
    // MARK: - UI Components
    
    var imageStackView = CustomImageStackView(image: UIImage(named: "animalPhoto")!)
    var warningMessage = CustomWarningLabel(text: "", color: UIColor.styledErrorRed)
    let progressView = CustomProgressStackView()
    let headerStackView = UIStackView()
    
    var currentUserNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.styledLightFont(size: 17)
        label.textColor = UIColor.styledDarkGray
        label.numberOfLines = 2
        return label
    }()
    let downloadButton: UIButton = {
        let downloadButton = UIButton(type: .custom)
        let image = UIImage(systemName: "square.and.arrow.down")
        downloadButton.setImage(image, for: .normal)
        downloadButton.tintColor = UIColor.styledErrorRed
        downloadButton.addTarget(self, action: #selector(downloadPhotoButtonTapped), for: .touchUpInside)
        
        return downloadButton
    }()
    private let commentTextField: UITextField = {
        let textField = CustomTextField(iconName: "pencil",fontStyle: UIFont.styledLightFont(size: 14), placeholderStr: "Comment..")
        return textField
    }()
    let commentButton: UIButton = {
        let commentButton = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(pointSize: 40) // Adjust size as needed
        let image = UIImage(systemName: "arrow.up.square.fill", withConfiguration: configuration)
        commentButton.setImage(image, for: .normal)
        commentButton.tintColor = UIColor.systemBlue
        
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        
        return commentButton
    }()
    
    
    // Add a table view to display comments
    private lazy var commentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        return tableView
    }()
    
    
    
    // MARK: - Init
    
    init(post: PostModel, user: UserModel) {
        self.post = post
        self.user = user
        self.imageUrl = post.photoURL
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(post)
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = UIColor.styledGreen
        
        navigationItem.backBarButtonItem?.isHidden = false
        
        isCurrentUser = AuthService.shared.isCurrentUser(user: user)
        // Load image asynchronously using SDWebImage
        if let imageUrl = URL(string: imageUrl!) {
            imageStackView.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"), options: [], completed: nil)
        } else {
            imageStackView.imageView.image = UIImage(named: "animalPhoto")
        }
        
        setupHeaderUI()
        setupUI()
        setupCommentsUI()
        
    }
    
    
    // MARK: - Header UI Setup
    
    func setupHeaderUI(){
        
        headerStackView.backgroundColor = .systemGray6
        view.addSubview(headerStackView)
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.2)
        }
        
        headerStackView.addSubview(currentUserNameLabel)
        currentUserNameLabel.text = user.name
        currentUserNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(10)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        
        // URL Label
        let urlLabel = UILabel()
        if let url = imageUrl {
            urlLabel.text = "Photo URL : \n \(url)"
        }
        urlLabel.font = UIFont.styledLightFont(size: 10)
        urlLabel.textColor = UIColor.styledDarkGray
        urlLabel.numberOfLines = 0
        urlLabel.lineBreakMode = .byWordWrapping
        
        headerStackView.addSubview(urlLabel)
        urlLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.top.equalTo(currentUserNameLabel.snp.bottom).offset(20)
        }
        
        
        // Download button
        headerStackView.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.trailing.equalTo(-30)
            make.top.equalTo(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        view.addSubview(headerStackView)
        
        
    }
    
    
    
    // MARK: - UI Setup
    
    func setupUI(){
        
        // Image Stack
        view.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(view.safeAreaLayoutGuide.snp.width).multipliedBy(0.6)
            make.top.equalTo(headerStackView.snp.bottom).offset(20)
        }
        
        // Warning Message Label
        warningMessage.font = UIFont.styledHeavyFont(size: 12)
        view.addSubview(warningMessage)
        warningMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(imageStackView.snp.top).offset(-6)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(20)
        }
        
        //Progress View Stack
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
        progressView.isHidden = true
        view.bringSubviewToFront(progressView)
    }
    
    
    // MARK: -  Comments UI Setup  
    
    func  setupCommentsUI(){
        
        // User Comments
        
        var commentsStackView = UIStackView()
        
        commentsStackView.backgroundColor = .systemPink
        view.addSubview(commentsStackView)
        
        commentsStackView.snp.makeConstraints { make in
            make.top.equalTo(imageStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.2)
        }
        commentsStackView.addSubview(commentsTableView)
        commentsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // Adjust constraints to fit the table view properly
        }
        
        
        // Comment text field and button
        var leaveCommentStackView = UIStackView()
        leaveCommentStackView.backgroundColor = .white
        view.addSubview(leaveCommentStackView)
        
        leaveCommentStackView.snp.makeConstraints { make in
            make.top.equalTo(commentsStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.1)
        }
        
        leaveCommentStackView.addSubview(commentTextField)
        commentTextField.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.equalTo(10)
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        leaveCommentStackView.addSubview(commentButton)
        commentButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(0)
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        
        reloadCommentData()
        
    }
    
    
    
    
    // MARK: - FUNCTIONS

    
    
    
    // MARK: BUTTON FUNCTIONS
    
    //Download Photo from storage
    @objc func downloadPhotoButtonTapped(){
        progressView.isHidden = false
        downloadButton.isEnabled = false
        warningMessage.text = ""
        
        Service.shared.downloadPhotoToGallery(withURL: imageUrl!){  [self] result in
            switch result {
            case .failure(let error):
                warningMessage.text = "Error downloading photo."
                warningMessage.textColor = UIColor.styledErrorRed
                progressView.isHidden = true
                downloadButton.isEnabled = true
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    saveImageToPhotos(image)
                } else {
                    print("Error: Failed to convert data to image")
                    progressView.isHidden = true
                }
            }
        }
    }
    
    @objc func commentButtonTapped() {
        
        leaveComment(currentUserID: AuthService.shared.userSession!)
        
    }
    
    
    
    // MARK: - Leave Comment
    func leaveComment(currentUserID: String) {
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            // Handle empty comment text
            return
        }
        
        PostService.shared.leaveComment(currentUserID: currentUserID, postID: post.id, commentText: commentText) { result in
            switch result {
            case .success:
                // Update UI or show success message if needed
                DispatchQueue.main.async { [self] in
                    // Clear the comment text field
                    commentTextField.text = ""
                    // Dismiss the keyboard
                    view.endEditing(true)
                    // Reload comments table view to reflect the new comment
                    reloadCommentData()
                }
            case .failure(let error):
                // Handle error
                print("Error leaving comment: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Reload comments
    func reloadCommentData() {
        
        PostService.shared.getPost(postID: post.id) { updatedPost in
            // Yeni yorumlarla post modelini güncelle
            self.post = updatedPost!
            // TableView'ı güncellemek için ana iş parçacığında çalıştır
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
        }
    }
    
    
    
    // MARK: Save Image to Gallery
    func saveImageToPhotos(_ image: UIImage) {
        DispatchQueue.global().async { // Ana iş parçacığında çalıştır
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { [self] success, error in
                if success {
                    DispatchQueue.main.async { [self] in
                        warningMessage.text = "Image saved successfully."
                        warningMessage.textColor = UIColor.systemGreen
                        progressView.isHidden = true
                        downloadButton.isEnabled = true
                    }
                } else if let error = error {
                    print("Error saving image: \(error.localizedDescription)")
                } else {
                    print("Unknown error saving image")
                }
            }
        }
    }
    
}

// MARK: - Table View Comments

extension PhotoDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // Commets Count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    // Comments line
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = post.comments[indexPath.row]
        
        AuthService.shared.getSomeUser(with: comment.commenterID) { user in
            
            cell.textLabel?.text = "\(user!.name)  :  \(comment.commentText)"
            cell.textLabel?.font = UIFont.styledLightFont(size: 13)
            
        }
       
        return cell
    }
    // comment size
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 30
    }
}
