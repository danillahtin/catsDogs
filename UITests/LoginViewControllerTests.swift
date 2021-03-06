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
import UI


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
    
    func test_skipButtonTap_notifies() {
        let sut = makeSut()
        
        var skippedCount = 0
        sut.didSkip = { skippedCount += 1 }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(skippedCount, 0)
        sut.simulateSkipButtonTapped()
        XCTAssertEqual(skippedCount, 1)
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
    
    func simulateSkipButtonTapped() {
        skipButton.triggerTap()
    }
}
