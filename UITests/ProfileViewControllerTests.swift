//
//  ProfileViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import UIKit


class ProfileViewController: UIViewController {
    let profileViewContainerView = UIView()
    let signInButtonContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileViewContainerView.isHidden = true
    }
}


class ProfileViewControllerTests: XCTestCase {
    func test() {
        let sut = makeSut()
    }
    
    func test_initialStateIsNotAuthorized() {
        let sut = makeSut()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isSignInButtonHidden, false)
        XCTAssertEqual(sut.isProfileViewHidden, true)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> ProfileViewController
    {
        let sut = ProfileViewController()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}


private extension ProfileViewController {
    var isSignInButtonHidden: Bool {
        signInButtonContainerView.isHidden
    }
    
    var isProfileViewHidden: Bool {
        profileViewContainerView.isHidden
    }
}
