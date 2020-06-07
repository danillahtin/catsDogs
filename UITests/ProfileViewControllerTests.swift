//
//  ProfileViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import UIKit


enum ProfileState {
    case authorized(String)
    case unauthorized
}

class ProfileViewController: UIViewController {
    let profileViewContainerView = UIView()
    let signInButtonContainerView = UIView()
    let profileNameLabel = UILabel()
    
    private var state: ProfileState = .unauthorized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        render(state: state)
    }
    
    func profileUpdated(state: ProfileState) {
        self.state = state
        
        render(state: state)
    }
    
    func render(state: ProfileState) {
        switch state {
        case .authorized(let user):
            signInButtonContainerView.isHidden = true
            profileViewContainerView.isHidden = false
            profileNameLabel.text = user
        case .unauthorized:
            signInButtonContainerView.isHidden = false
            profileViewContainerView.isHidden = true
        }
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
    
    func test_rendersState_whenStateIsUpdatedBeforeLoadView() {
        assertStateIsRenderedOnLoadView(.unauthorized)
        assertStateIsRenderedOnLoadView(.authorized("User"))
        assertStateIsRenderedOnLoadView(.authorized("Another user"))
    }
    
    func test_rendersState_whenStateIsUpdatedAfterLoadView() {
        let sut = makeSut()
        sut.loadViewIfNeeded()
        
        sut.profileUpdated(state: .unauthorized)
        assert(sut: sut, renders: .unauthorized)
        
        sut.profileUpdated(state: .authorized("User"))
        assert(sut: sut, renders: .authorized("User"))
        
        sut.profileUpdated(state: .unauthorized)
        assert(sut: sut, renders: .unauthorized)
        
        sut.profileUpdated(state: .authorized("Another user"))
        assert(sut: sut, renders: .authorized("Another user"))
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
    
    private func assertStateIsRenderedOnLoadView(
        _ state: ProfileState,
        file: StaticString = #file,
        line: UInt = #line)
    {
        let sut = makeSut()
        
        sut.profileUpdated(state: state)
        sut.loadViewIfNeeded()
        
        assert(sut: sut, renders: state, file: file, line: line)
    }
    
    private func assert(
        sut: ProfileViewController,
        renders state: ProfileState,
        file: StaticString = #file,
        line: UInt = #line)
    {
        switch state {
        case .authorized(let user):
            XCTAssertEqual(sut.isSignInButtonHidden, true, file: file, line: line)
            XCTAssertEqual(sut.isProfileViewHidden, false, file: file, line: line)
            XCTAssertEqual(sut.renderedProfileName, user, file: file, line: line)
        case .unauthorized:
            XCTAssertEqual(sut.isSignInButtonHidden, false, file: file, line: line)
            XCTAssertEqual(sut.isProfileViewHidden, true, file: file, line: line)
        }
    }
}


private extension ProfileViewController {
    var isSignInButtonHidden: Bool {
        signInButtonContainerView.isHidden
    }
    
    var isProfileViewHidden: Bool {
        profileViewContainerView.isHidden
    }
    
    var renderedProfileName: String? {
        profileNameLabel.text
    }
}
