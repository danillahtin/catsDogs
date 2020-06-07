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
    var didLogin: () -> () = {}
    
}

class LoginViewControllerTests: XCTestCase {
    
    func test_loadView_doesNotLogin() {
        let sut = makeSut()
        
        var loginCallCount = 0
        sut.didLogin = {
            loginCallCount += 1
        }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loginCallCount, 0)
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
