//
//  PushAuthFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core
import UI
@testable import CatsDogs


final class LoginRequestSpy {
    var completions: [(Error) -> ()] = []
    private(set) var requestedCredentials: [Credentials] = []
    
    func start(credentials: Credentials) {
        completions.append({ _ in })
        requestedCredentials.append(credentials)
    }
    
    func complete(with error: Error, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard completions.indices.contains(index) else {
            XCTFail(
                "Completion at index \(index) not found, has only \(completions.count) completions",
                file: file,
                line: line)
            return
        }
        
        completions[index](error)
    }
}

final class PushAuthFlow {
    let loginRequest: LoginRequestSpy
    let navigationController: UINavigationControllerProtocol
    let onComplete: () -> ()
    
    init(loginRequest: LoginRequestSpy,
         navigationController: UINavigationControllerProtocol,
         onComplete: @escaping () -> ())
    {
        self.loginRequest = loginRequest
        self.navigationController = navigationController
        self.onComplete = onComplete
    }
    
    func start() {
        let vc = LoginViewController()
        vc.didSkip = onComplete
        vc.didLogin = loginRequest.start
        
        navigationController.setViewControllers([vc], animated: true)
    }
}

class PushAuthFlowTests: XCTestCase {
    func test_init_doesNotSet() {
        let (_, navigationController) = makeSut()

        XCTAssertEqual(navigationController.messages, [])
    }
    
    func test_start_setsViewController() {
        let (sut, navigationController) = makeSut()
        
        sut.start()
        
        XCTAssertEqual(navigationController.messages.count, 1)
        XCTAssertEqual(navigationController.messages[0].viewControllers?.count, 1)
        XCTAssertEqual(navigationController.messages[0].animated, true)
        
        let loginViewController = getLoginViewController(from: navigationController)

        XCTAssertNotNil(loginViewController)
    }
    
    func test_loginViewControllerDidSkip_completes() {
        var completedCount = 0
        let (sut, navigationController) = makeSut(onComplete: { completedCount += 1 })
        
        sut.start()
        let loginViewController = getLoginViewController(from: navigationController)

        XCTAssertEqual(completedCount, 0)
        loginViewController?.didSkip()
        
        XCTAssertEqual(completedCount, 1)
    }
    
    func test_loginViewControllerDidLogin_requestsLogin() {
        let loginRequest = LoginRequestSpy()
        let (sut, navigationController) = makeSut(loginRequest: loginRequest)
        
        sut.start()

        XCTAssertEqual(loginRequest.requestedCredentials, [])
        
        getLoginViewController(from: navigationController)?
            .simulateLogin(login: "login", password: "password")
        
        XCTAssertEqual(loginRequest.requestedCredentials, [
            Credentials(login: "login", password: "password")
        ])
        
        getLoginViewController(from: navigationController)?
            .simulateLogin(login: "another login", password: "another password")
        
        XCTAssertEqual(loginRequest.requestedCredentials, [
            Credentials(login: "login", password: "password"),
            Credentials(login: "another login", password: "another password"),
        ])
    }
    
    func test_loginCompletionWithError_doesNotComplete() {
        let loginRequest = LoginRequestSpy()
        var completedCount = 0
        
        let (sut, navigationController) = makeSut(
            loginRequest: loginRequest,
            onComplete: { completedCount += 1 })
        
        sut.start()
        getLoginViewController(from: navigationController)?
            .simulateLogin(login: "login", password: "password")
        
        loginRequest.complete(with: anyError())
        
        XCTAssertEqual(completedCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        loginRequest: LoginRequestSpy = .init(),
        onComplete: @escaping () -> () = {},
        file: StaticString = #file,
        line: UInt = #line) -> (sut: PushAuthFlow, navigationController: NavigationControllerSpy)
    {
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = PushAuthFlow(
            loginRequest: loginRequest,
            navigationController: navigationControllerSpy,
            onComplete: onComplete)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: navigationControllerSpy, file: file, line: line)
        trackMemoryLeaks(for: loginRequest, file: file, line: line)
        
        return (sut, navigationControllerSpy)
    }
    
    private func getLoginViewController(from navigationController: NavigationControllerSpy) -> LoginViewController? {
        let rootVc = navigationController.messages[0].viewControllers?.first
        rootVc?.loadViewIfNeeded()
        
        return rootVc as? LoginViewController
    }
}


private extension LoginViewController {
    func simulateLogin(login: String, password: String) {
        loginTextField.text = login
        passwordTextField.text = password
        
        loginButton.triggerTap()
    }
}
