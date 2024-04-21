//
//  SignUpViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 14.03.2024.
//



import UIKit
import SnapKit
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let nameSurnameTextField: UITextField = {
        let textField = CustomTextField(iconName: "person",fontStyle: UIFont.styledLightFont(size: 14), placeholderStr: "Name Surname")
        return textField
    }()
    private let emailTextField: UITextField = {
        let textField = CustomTextField(iconName: "envelope",fontStyle: UIFont.styledLightFont(size: 14), placeholderStr: "Email")
        return textField
    }()
    private let passwordTextField: UITextField = {
        let textField = CustomTextField(iconName: "lock",fontStyle: UIFont.styledHeavyFont(size: 14), placeholderStr: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let passwordVerifyTextField: UITextField = {
        let textField = CustomTextField(iconName: "lock",fontStyle: UIFont.styledHeavyFont(size: 14), placeholderStr: "Verify password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    var warningMessage = CustomWarningLabel(text: "", color: UIColor.styledErrorRed)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        setupUI()
        
    }
    
    // MARK:  UI Setup
    func setupUI(){
        
        let imageView = UIImageView(image: UIImage(named: "register"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let signUpLabel = UILabel()
        signUpLabel.text = "Sign Up"
        signUpLabel.font = UIFont.boldSystemFont(ofSize: 30)
        signUpLabel.textColor = .white
        signUpLabel.numberOfLines = 2
        
        
        view.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        
        // MARK: TextFields
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(nameSurnameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(passwordVerifyTextField)
        
        view.addSubview(stackView)
        nameSurnameTextField.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        passwordVerifyTextField.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(signUpLabel.snp.bottom).offset(100)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        view.addSubview(warningMessage)
        
        warningMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(stackView.snp.top).offset(-10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(20)
        }
        
        // MARK: Buttons
        
        let signUpButton: UIButton = {
            let button = CustomButton(butonName: "SIGN UP", backgroundColor: UIColor.styledOrange, titleColor: .white, isShadow: true)
            button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.styledHeavyFont(size: 15)
            return button
        }()
        
        
        view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(30)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(60)
        }
        
        let signInButton: UIButton = {
            let button = CustomButton(butonName: "You already have an account?", backgroundColor: .clear, titleColor: UIColor.white, isShadow: false)
            button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = UIFont.styledLightFont(size: 15)
            return button
        }()
        
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(signUpButton.snp.bottom).offset(10)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        
        
        
        
    }
    // MARK: - FUNCTIONS
    
    
    
    
    
    // MARK: BUTTON FUNCTIONS
    @objc private func signUpButtonTapped()  {
        
        guard signUpFormValidate() else { return }
        
        AuthService.shared.createUserWithEmailAndPassword(email: emailTextField.text!, password: passwordTextField.text!, username: nameSurnameTextField.text!) { [self] error in
            if let error = error {
                warningMessage.text = error.localizedDescription
                return
            }
            DispatchQueue.main.async {
                self.signInButtonTapped()
            }
        }
    }
    @objc private func signInButtonTapped() {
        
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true, completion: nil)
        
    }
    
    
    // MARK: Email Validate
    
    private func signUpFormValidate()-> Bool{
        // Check if the email is in a valid format
        guard let name = nameSurnameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let passwordVerify = passwordVerifyTextField.text else {
            warningMessage.text = "Please fill in all fields."
            warningMessage.isHidden = false
            return false
        }
        
        if !isValidEmail(email) {
            warningMessage.text = "Please enter a valid email address."
            warningMessage.isHidden = false
            return false
        }
        if  name == "" {
            warningMessage.text = "Please enter your name."
            warningMessage.isHidden = false
            return false
        }
        
        // Check if the email ends with "neonapps.co"
        if !email.hasSuffix("neonapps.co") {
            warningMessage.text = "Please use an email ending with 'neonapps.co'."
            warningMessage.isHidden = false
            return false
        }
        
        // Check if the password and password verification match
        if password != passwordVerify {
            warningMessage.text = "Passwords do not match."
            warningMessage.isHidden = false
            return false
        }
        return true
        
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    
    
    
}
