//
//  LoginViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class LoginViewController {}

class LoginViewControllerTests: XCTestCase {
    
    func test() {
        let sut = makeSut()
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
