//
//  ProfileViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core
import UI


class ProfileViewControllerTests: XCTestCase {
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
    
    func test_signInButtonTapped_notifies() {
        let sut = makeSut()
        
        var signInCallsCount = 0
        sut.onSignIn = { signInCallsCount += 1 }
        
        sut.loadViewIfNeeded()
        sut.profileUpdated(state: .unauthorized)
        
        XCTAssertEqual(signInCallsCount, 0)
        sut.simulateSignInButtonTapped()
        
        XCTAssertEqual(signInCallsCount, 1)
        sut.simulateSignInButtonTapped()
        
        XCTAssertEqual(signInCallsCount, 2)
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
            XCTAssertEqual(sut.isLogoutButtonHidden, false, file: file, line: line)
            XCTAssertEqual(sut.isProfileViewHidden, false, file: file, line: line)
            XCTAssertEqual(sut.renderedProfileName, user, file: file, line: line)
        case .unauthorized:
            XCTAssertEqual(sut.isSignInButtonHidden, false, file: file, line: line)
            XCTAssertEqual(sut.isLogoutButtonHidden, true, file: file, line: line)
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
    
    var isLogoutButtonHidden: Bool {
        logoutButtonContainerView.isHidden
    }
    
    var renderedProfileName: String? {
        profileNameLabel.text
    }
    
    func simulateSignInButtonTapped() {
        signInButton.triggerTap()
    }
}
