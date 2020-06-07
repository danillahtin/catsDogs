//
//  LoginViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import UIKit


final class LoginViewController: UIViewController {
    let loginButton = UIButton()
    let loginTextField = UITextField()
    var didLogin: (String) -> () = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func onLoginButtonTapped() {
        didLogin(loginTextField.text ?? "")
    }
}

class LoginViewControllerTests: XCTestCase {
    
    func test_loginButtonTap_logsInWithCorrectLogin() {
        let sut = makeSut()
        
        var retrievedLogins = [String]()
        sut.didLogin = {
            retrievedLogins.append($0)
        }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(retrievedLogins, [])
        
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(retrievedLogins, [""])
        
        sut.simulateLoginInput("login")
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(retrievedLogins, ["", "login"])
        
        sut.simulateLoginInput("another login")
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(retrievedLogins, ["", "login", "another login"])
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
}
