//
//  CustomImageView.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 19.03.2024.
//

import Foundation
import UIKit
import SnapKit

class CustomImageStackView : UIStackView {
    
    var imageView = UIImageView()
    
    
    init(image: UIImage) {
        self.imageView.image = image

        super.init(frame: .zero)
        setupStackUI()
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupStackUI(){
        
        //shadow
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 5
        shadowView.layer.cornerRadius = 30
        shadowView.backgroundColor = .white
        shadowView.layer.masksToBounds = false
        
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 30
        

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
     
        
        
        
    }
    
}
