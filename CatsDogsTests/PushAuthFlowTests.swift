//
//  PushAuthFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import UI
@testable import CatsDogs


final class PushAuthFlow {
    let navigationController: UINavigationControllerProtocol
    let onComplete: () -> ()
    
    init(navigationController: UINavigationControllerProtocol,
         onComplete: @escaping () -> ())
    {
        self.navigationController = navigationController
        self.onComplete = onComplete
    }
    
    func start() {
        let vc = LoginViewController()
        vc.didSkip = onComplete
        
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
        
        let rootVc = navigationController.messages[0].viewControllers?.first
        let loginViewController = rootVc as? LoginViewController

        XCTAssertNotNil(loginViewController)
    }
    
    func test_loginViewControllerDidSkip_completes() {
        var completedCount = 0
        let (sut, navigationController) = makeSut(onComplete: { completedCount += 1 })
        
        sut.start()
        let rootVc = navigationController.messages[0].viewControllers?.first
        let loginViewController = rootVc as? LoginViewController

        XCTAssertEqual(completedCount, 0)
        loginViewController?.didSkip()
        
        XCTAssertEqual(completedCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        onComplete: @escaping () -> () = {},
        file: StaticString = #file,
        line: UInt = #line) -> (sut: PushAuthFlow, navigationController: NavigationControllerSpy)
    {
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = PushAuthFlow(
            navigationController: navigationControllerSpy,
            onComplete: onComplete)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: navigationControllerSpy, file: file, line: line)
        
        return (sut, navigationControllerSpy)
    }
    
    private func getLoginViewController(from navigationController: NavigationControllerSpy) -> LoginViewController? {
        let rootVc = navigationController.messages[0].viewControllers?.first
        return rootVc as? LoginViewController
    }
}
