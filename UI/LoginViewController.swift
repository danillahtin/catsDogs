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
    public let loginButton = UIButton()
    public let loginTextField = UITextField()
    public let passwordTextField = UITextField()
    public var didLogin: (Credentials) -> () = { _ in }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func onLoginButtonTapped() {
        didLogin(Credentials(login: loginTextField.text ?? "",
                             password: passwordTextField.text ?? ""))
    }
}
