//
//  EmailVerifyViewController.swift
//  DaringDuckFirebase
//
//  Created by Rabia Abdioğlu on 18.03.2024.
//
import UIKit
import SnapKit
import Firebase

class EmailVerifyViewController: UIViewController {
    
    var user: UserModel?
    
    
    // MARK: - UI Components
    
    var warningMessage = CustomWarningLabel(text: "Please verify your email.", color: .gray)
    private let backButton = CustomBarButton(iconName: "chevron.left")
    private let refreshButton = CustomBarButton(iconName: "arrow.clockwise")
    
    
    let emailVerificationButton: UIButton = {
        let button = CustomButton(butonName: "Send email verification.", backgroundColor: UIColor.styledGreen, titleColor: UIColor.white, isShadow: false)
        button.addTarget(self, action: #selector(sendEmailVerification), for: .touchUpInside)
        button.titleLabel?.font = UIFont.styledHeavyFont(size: 15)
        return button
    }()
    
    
    init(user: UserModel?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        
    }
    
    // MARK: - UI Setup
    
    func setupUI(){
        // Image View
        let imageView = UIImageView(image: UIImage(named: "community2"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(20)
            make.height.equalTo(100)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(200)
        }
        
        
        // Back Button
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(20)
        }
        // Refresh Button
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        view.addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalTo(-20)
        }
        
        // Email Verify Button
        view.addSubview(emailVerificationButton)
        emailVerificationButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
        }
        
        
        // Warning Message
        warningMessage.textAlignment = .center
        view.addSubview(warningMessage)
        warningMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(emailVerificationButton.snp.top).offset(-30)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
    }
    
    
    // MARK: - FUNCTIONS
    
    // MARK: - Email verify

    @objc private func sendEmailVerification() {
        // is email verified
        AuthService.shared.isEmailVerified { [self] isVerified in
            if isVerified {
                dismiss(animated: true, completion: nil)
                
            } else {
                // Send link to email
                AuthService.shared.sendSignInLinkToEmail(email: user!.email) { [self] error in
                    if let error = error {
                        warningMessage.text = "An error occurred while sending the email.\nPlease try again."
                        warningMessage.textColor = .systemRed
                    } else {
                        if let email = self.user?.email {
                            self.warningMessage.text = "An email has been sent to \(email). \nAfter verification, please refresh this page."
                        }
                        self.warningMessage.textColor = .systemGreen
                        self.emailVerificationButton.isEnabled = false
                    }
                }
            }
        }
    }
    
    
    // MARK:  Refresh button
    
    //Refresh button for navigate Home when email verifiy
    
    @objc private func refreshButtonTapped() {
        AuthService.shared.isEmailVerified { isVerified in
            if isVerified {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    @objc private func handleBackButtonTapped() {
        self.dismiss(animated: true)
    }
    
}

