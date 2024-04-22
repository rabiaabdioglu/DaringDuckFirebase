//
//  SignInViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth


class SignInViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let emailTextField: UITextField = {
        let textField = CustomTextField(iconName: "envelope",fontStyle: UIFont.styledLightFont(size: 14), placeholderStr: "Email")
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = CustomTextField(iconName: "lock",fontStyle: UIFont.styledHeavyFont(size: 14), placeholderStr: "Password")
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    var warningMessage = CustomWarningLabel(text: "", color: UIColor.styledErrorRed)
    
//    override func viewWillAppear(_ animated: Bool) {
//        if Auth.auth().currentUser != nil {
//            self.dismiss(animated: true)
//        }
//        
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        setupUI()
        
    }
    
    // MARK: - UI Setup
    func setupUI(){
        // Image View
        let imageView = UIImageView(image: UIImage(named: "login"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Welcome Label
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome\nSign In"
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        welcomeLabel.textColor = .white
        welcomeLabel.numberOfLines = 2
        
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        
        
        
        // Email and Password field
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(30)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        // Warning Message
        view.addSubview(warningMessage)
        warningMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(emailTextField.snp.top).offset(-10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(20)
        }
        
        
        // MARK: UI Buttons
        
        let forgotPassword = CustomButton(butonName: "Forgot your password?", backgroundColor: .clear, titleColor: UIColor.gray, isShadow: false)
        forgotPassword.addTarget(self, action: #selector(forgotYourPassword), for: .touchUpInside)
        forgotPassword.titleLabel?.font = UIFont.styledLightFont(size: 12)
        forgotPassword.contentHorizontalAlignment = .left
        
        view.addSubview(forgotPassword)
        forgotPassword.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        
        // SIGN IN Button
        let signInButton = CustomButton(butonName: "SIGN IN", backgroundColor: UIColor.styledGreen, titleColor: .white, isShadow: true)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signInButton.titleLabel?.font = UIFont.styledHeavyFont(size: 15)
        
        
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(forgotPassword.snp.bottom).offset(10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(60)
        }
        
        // SIGN UP Button
        let signUpButton = CustomButton(butonName: "You dont have an account?", backgroundColor: .clear, titleColor: UIColor.gray, isShadow: false)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        signUpButton.titleLabel?.font = UIFont.styledLightFont(size: 15)
        
        view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(signInButton.snp.bottom).offset(10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        
        
        
    }
    // MARK: - FUNCTIONS
    
    
    
    
    
    // MARK: BUTTON FUNCTIONS
    @objc private func signInButtonTapped() {
        
        guard signInFormValidate() else { return }
        
        AuthService.shared.signInWithEmailAndPassword(withEmail: emailTextField.text! , password: passwordTextField.text!) { [self] error in
            if let error = error {
                warningMessage.text = error.localizedDescription
                return
            }
            else{
                AuthService.shared.loadCurrentUser{ [self] user in
                    AuthService.shared.isEmailVerified { isVerified in
                        if !isVerified{
                            let emailVerifyVc = EmailVerifyViewController(user: user)
                            emailVerifyVc.modalPresentationStyle = .fullScreen
                            self.present(emailVerifyVc, animated: true, completion: nil)
                        }
                        else{
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @objc private func signUpButtonTapped() {
        
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    @objc private func forgotYourPassword() {
        let forgotPassVC = ForgotPasswordController()
        forgotPassVC.modalPresentationStyle = .fullScreen
        self.present(forgotPassVC, animated: true, completion: nil)
    }
    
    
    // MARK: Form control
    
    private func signInFormValidate()-> Bool{
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            warningMessage.text = "Please fill in all fields."
            if passwordTextField.text == "" {
                warningMessage.text = "Please enter password." }
            warningMessage.isHidden = false
            return false
        }
        
        
        if AuthService.shared.isValidEmail(email) == false {
            warningMessage.text = "Please enter a valid email address."
            warningMessage.isHidden = false
            return false
        }
        
        return true
    }
    
}
