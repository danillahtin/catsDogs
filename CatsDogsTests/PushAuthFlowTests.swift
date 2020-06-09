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
    
    init(navigationController: UINavigationControllerProtocol) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.setViewControllers([LoginViewController()], animated: true)
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
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: PushAuthFlow, navigationController: NavigationControllerSpy)
    {
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = PushAuthFlow(navigationController: navigationControllerSpy)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: navigationControllerSpy, file: file, line: line)
        
        return (sut, navigationControllerSpy)
    }
}
