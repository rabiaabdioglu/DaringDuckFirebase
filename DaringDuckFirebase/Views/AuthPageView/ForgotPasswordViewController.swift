//
//  ForgotPasswordController.swift
//  swift-login-system-tutorial
//
//  Created by YouTube on 2022-10-26.
//

import UIKit
import SnapKit
import FirebaseAuth

class ForgotPasswordController: UIViewController {
    
    // MARK: - UI Components
    
    private let emailTextField =  CustomTextField(iconName: "envelope",fontStyle: UIFont.styledLightFont(size: 14), placeholderStr: "Email")
    
    private let resetPasswordButton  = CustomButton(butonName: "Reset Password", backgroundColor: UIColor.styledGreen, titleColor: .white, isShadow: true)
    
    var warningMessage = CustomWarningLabel(text: "", color: UIColor.styledErrorRed)
    
    private let backButton = CustomBarButton(iconName: "chevron.left" )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        // Image View
        let imageView = UIImageView(image: UIImage(named: "login"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Back Button
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(20)
        }
        
        // Email and Pass Fields
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(50)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        
        resetPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        
        self.view.addSubview(resetPasswordButton)
        resetPasswordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        // Warning Message Label
        view.addSubview(warningMessage)
        warningMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(emailTextField.snp.top).offset(-5)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(60)
        }
        
    }
    
    
    // MARK: - FUNCTIONS
    
    // MARK:  Reset Password Func
    @objc private func didTapForgotPassword() {
        let email = self.emailTextField.text ?? ""
        
        if AuthService.shared.isValidEmail(email) == false {
            warningMessage.text = "Please enter a valid email"
            return
        }
        // Send reset pass link to mail
        AuthService.shared.sendPasswordResetEmail(email: email) { [ self] error in
            if let error = error {
                warningMessage.text =  "An error occurred while sending the reset email."
            }
            else{
                warningMessage.textColor = .green
                warningMessage.text = "Password reset mail email has been sent to \n \(email)."
            }
        }
    }
    
    @objc private func handleBackButtonTapped() {
        self.dismiss(animated: true)
    }
}
