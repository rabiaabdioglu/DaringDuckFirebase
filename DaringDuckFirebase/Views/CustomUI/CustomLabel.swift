//
//  CustomLabel.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//

import Foundation

import UIKit

class CustomWarningLabel: UILabel {
    
    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        configureLabel(text: text, color: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLabel(text: "", color: .black)
    }
    
    private func configureLabel(text: String, color: UIColor) {
        self.text = text
        self.textColor = color
        self.font = UIFont.styledLightFont(size: 12)
        self.numberOfLines = 3
        self.lineBreakMode = .byWordWrapping
    }
}
