//
//  ProfileViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//

import Foundation
import UIKit
import SDWebImage

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
  
    private var collectionView: UICollectionView?
    
    var posts = [PostModel]()
    var user = AuthService.shared.userData
    
    let headerStackView = UIStackView()
    
    var currentUserNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.styledLightFont(size: 17)
        label.textColor = UIColor.styledDarkGray
        label.numberOfLines = 2
        return label
    }()
    var currentMailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.styledLightFont(size: 12)
        label.textColor = UIColor.styledDarkGray
        label.numberOfLines = 2
        return label
    }()
    
    init(user: UserModel?) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.updateLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        getPosts()
        self.user = AuthService.shared.userData
                
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Profile"
        
        getPosts()
        setupHeaderUI()
        setupCollectionUI()
        
    }
    // MARK: - Header UI
    /// Include:   User Name - UserMail - SıgnOut Button
    
    func setupHeaderUI(){
        // Header Stack
        headerStackView.backgroundColor = .white
        view.addSubview(headerStackView)
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.2)
        }
        // User Name Label
        headerStackView.addSubview(currentUserNameLabel)
        currentUserNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(10)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        // User Mail Label
        headerStackView.addSubview(currentMailLabel)
        currentMailLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(currentUserNameLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
        // Sign Out Button
        let signOutButton = UIButton(type: .custom)
        let image = UIImage(systemName: "power.circle.fill")
        signOutButton.setImage(image, for: .normal)
        signOutButton.tintColor = UIColor.styledErrorRed
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        
        headerStackView.addSubview(signOutButton)
        signOutButton.snp.makeConstraints { make in
            make.trailing.equalTo(-30)
            make.top.equalTo(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        
        view.addSubview(headerStackView)
        
    }
    // MARK: - Collection UI
    // Include: Collection View, Top Divider UI
    func setupCollectionUI (){
        
       
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView!.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = .systemGray6
        
        collectionView?.showsVerticalScrollIndicator = false
        
        guard let collectionView = collectionView else { return }
        
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.7)
        }
        
        let dividerView = UIView()
        dividerView.backgroundColor = .lightGray
        view.addSubview(dividerView)
        dividerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(collectionView.snp.top)
        }
        
        
        
    }
    
    // MARK: - Functions
    
    // Get Current user all posts
    func getPosts() {
        guard let user = user else { return }
        PostService.shared.getUserPosts(for: user) { userPosts,  error in
            if let error = error {
                print("Error fetching posts: \(error)")
                return
            }
            self.posts = userPosts
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    // Go detail VC
    func showDetailVC(postID : String){
        
        PostService.shared.getPost(postID: postID) { [self] post in
            let detailVC = PhotoDetailViewController(post: post!, user: user!)
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
    // SignOut Button
    @objc func signOutTapped() {
        AuthService.shared.signOut()
        DispatchQueue.main.async {
            let loginViewController = SignInViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true, completion: nil)
        }
        
    }
    
    // Name label update for init
    private func updateLabel() {
        guard let user = self.user else { return }
        DispatchQueue.main.async {
            self.currentUserNameLabel.text = user.name
            self.currentMailLabel.text = user.email
        }
    }
}


// MARK: - Collection

extension ProfileViewController {
    
    // Post Count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    // Post Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let post = posts[indexPath.item]
        
        // Load image asynchronously using SDWebImage
        if let imageUrl = URL(string: post.photoURL) {
            cell.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"), options: [], completed: nil)
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
    // Post size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.size.width - 50) / 2
        return CGSize(width: width, height: width)
    }
    // Selected Post
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        guard let url = URL(string: post.photoURL) else {
            print("Invalid photo URL")
            return
        }
        
        showDetailVC(postID: post.id)
        
    }
    
    
    
}
