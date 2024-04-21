//
//  CustomTextField.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//

import UIKit

class CustomTextField: UITextField {
    
    var padding: CGFloat = 35
    var iconName: String
    var fontStyle : UIFont
    var placeholderStr: String
    
    init(iconName: String, fontStyle: UIFont, placeholderStr: String) {
        self.iconName = iconName
        self.fontStyle = fontStyle
        self.placeholderStr = placeholderStr
        
        super.init(frame: .zero)
        setupTextUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupTextUI(){
        self.font =  fontStyle
        self.placeholder = placeholderStr
        self.tintColor = UIColor.orange
        
        self.backgroundColor = .white
        self.textColor = UIColor.styledDarkGray
        self.layer.cornerRadius = 8
        self.clipsToBounds = false
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
    
        // Left Image
        self.leftViewMode = .always
        let leftView = UIImageView()
        leftView.tintColor = UIColor.gray
        leftView.image = UIImage(systemName: iconName)
        
        self.addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(25)
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            
        }
        

        // Sharp shadow
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: padding + 10, y: 0, width: bounds.width - 50, height: bounds.height)
        return bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: padding + 10, y: 0, width: bounds.width - 50, height: bounds.height)
        return bounds
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: padding + 10, y: 0, width: bounds.width - 50, height: bounds.height)
        return bounds
    }

    
}
