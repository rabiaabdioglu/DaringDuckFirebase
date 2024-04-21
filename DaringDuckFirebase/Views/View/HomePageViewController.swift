//
//  HomePageViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//


import UIKit
import SnapKit
import Firebase

class HomePageViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var user = AuthService.shared.userData
    private var collectionView: UICollectionView?
    private var posts = [PostModel]()
    
    init(user: UserModel?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Feed"
        
        fetchPosts()
        setupCollectionView()
    }
    
    // Collection View UI
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
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
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height)
        }
    }
    
    // get all post for home page
    private func fetchPosts() {
        PostService.shared.getAllPosts { posts, error in
            if let error = error {
                print("Error fetching posts: \(error)")
                return
            }
            self.posts = posts
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
}

extension HomePageViewController {
    // Post Counts
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Post Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let post = posts[indexPath.item]
        
        if let imageUrl = URL(string: post.photoURL) {
            cell.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"), options: [], completed: nil)
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
    
    // Post size ( for home page 3 cell every line)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: width)
    }
    // Selected Post
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        showDetailVC(postID: post.id)
    }
    // Show detail vs
    private func showDetailVC(postID: String) {
        PostService.shared.getPost( postID: postID) { [ self] post in
            
            if let post = post {
                DispatchQueue.main.async {
                    // Get user detail with postedbyID and navigate Detail page
                    AuthService.shared.getSomeUser(with:  post.postedByID) { user in
                        let detailVC = PhotoDetailViewController(post: post, user: user!)
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            } else {
                print("Post not found")
            }
        }
    }
}

