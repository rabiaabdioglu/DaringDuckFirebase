//
//  CustomButton.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//

import Foundation

import UIKit

class CustomButton: UIButton {
    
    var titleColor : UIColor
    var butonName: String
    var isShadow: Bool
    var bgColor: UIColor
    
    init(butonName: String,backgroundColor: UIColor, titleColor: UIColor, isShadow: Bool) {
        self.butonName = butonName
        self.bgColor = backgroundColor
        self.titleColor = titleColor
        self.isShadow = isShadow

        super.init(frame: .zero)
        setupTextUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextUI(){
        
        self.setTitle(butonName, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = bgColor
        

        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        if isShadow {
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
            layer.cornerRadius = 10
        }
     
        
    }
    
}

// MARK: Back Bar Button

class CustomBarButton: UIButton {
    
    let iconName: String
    
    init(iconName: String) {
        self.iconName = iconName
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        let image = UIImage(systemName: iconName)
        setImage(image, for: .normal)
        tintColor = UIColor.styledGreen
    }
}
