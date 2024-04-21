//
//  CustomProgressStackView.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 19.03.2024.
//

import Foundation
import UIKit

class CustomProgressStackView: UIStackView {
    
    private let progressView = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {

        axis = .vertical
        alignment = .center
        distribution = .fill
        spacing = 20
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        backgroundView.layer.cornerRadius = 10
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // ProgressView
        progressView.color = .white
        progressView.startAnimating()
        backgroundView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
