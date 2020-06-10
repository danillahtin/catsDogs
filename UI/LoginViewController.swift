//
//  LoginViewController.swift
//  UI
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import Core


public final class LoginViewController: UIViewController {
    public let loginButton = UIButton(type: .system)
    public let skipButton = UIButton(type: .system)
    public let loginTextField = UITextField()
    public let passwordTextField = UITextField()
    public var didLogin: (Credentials) -> () = { _ in }
    public var didSkip: () -> () = {}
    
    public override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        loginTextField.borderStyle = .line
        loginTextField.placeholder = "Login"
        passwordTextField.borderStyle = .line
        passwordTextField.placeholder = "Password"
        
        loginButton.setTitle("Sign in", for: .normal)
        skipButton.setTitle("Skip", for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [
            loginTextField,
            passwordTextField,
            loginButton,
            skipButton,
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: 240),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
        
        self.view = view
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(onSkipButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func onLoginButtonTapped() {
        didLogin(Credentials(login: loginTextField.text ?? "",
                             password: passwordTextField.text ?? ""))
    }
    
    @objc
    private func onSkipButtonTapped() {
        didSkip()
    }
}
