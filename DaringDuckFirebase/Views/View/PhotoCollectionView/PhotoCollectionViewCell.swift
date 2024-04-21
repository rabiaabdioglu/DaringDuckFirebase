//
//  PhotoCollectionViewCell.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//
import UIKit
import FirebaseStorage
import Firebase

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage?
    var postId: String?
    
    
    static let identifier = "AppCollectionViewCell"
    weak var detailViewController: UIViewController?
    
    
    var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.image!.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(contentView.snp.width).multipliedBy(0.95)
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
    func configure(with image: UIImage)  {
        imageView.image = image
    }
    
}
