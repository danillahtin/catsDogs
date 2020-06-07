//
//  LoginViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import UIKit
import Core


final class LoginViewController: UIViewController {
    let loginButton = UIButton()
    let loginTextField = UITextField()
    let passwordTextField = UITextField()
    var didLogin: (Credentials) -> () = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func onLoginButtonTapped() {
        didLogin(Credentials(login: loginTextField.text ?? "",
                             password: passwordTextField.text ?? ""))
    }
}

class LoginViewControllerTests: XCTestCase {
    
    func test_loginButtonTap_logsInWithCorrectCredentials() {
        let sut = makeSut()
        
        var retrievedCredentials = [Credentials]()
        sut.didLogin = {
            retrievedCredentials.append($0)
        }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(retrievedCredentials, [])
        
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(retrievedCredentials, [
            Credentials(login: "", password: "")
        ])
        
        sut.simulateLoginInput("login")
        sut.simulatePasswordInput("password")
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(retrievedCredentials, [
            Credentials(login: "", password: ""),
            Credentials(login: "login", password: "password"),
        ])
        
        sut.simulateLoginInput("another login")
        sut.simulatePasswordInput("another password")
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(retrievedCredentials, [
            Credentials(login: "", password: ""),
            Credentials(login: "login", password: "password"),
            Credentials(login: "another login", password: "another password"),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> LoginViewController
    {
        let sut = LoginViewController()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}

private extension LoginViewController {
    func simulateLoginButtonTap() {
        loginButton.triggerTap()
    }
    
    func simulateLoginInput(_ login: String) {
        loginTextField.text = login
    }
    
    func simulatePasswordInput(_ password: String) {
        passwordTextField.text = password
    }
}
