//
//  MainFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class MainFlow {}

protocol UINavigationControllerProtocol {
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
}


class MainFlowTests: XCTestCase {
    func test_init_doesNotSet() {
        let (_, navigationController) = makeSut()
        
        XCTAssertEqual(navigationController.messages, [])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: MainFlow, navigationController: NavigationControllerSpy)
    {
        let navigationController = NavigationControllerSpy()
        let sut = MainFlow()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: navigationController, file: file, line: line)
        
        return (sut, navigationController)
    }
    
    
}

final class NavigationControllerSpy: UINavigationControllerProtocol {
    enum Message: Equatable {
        case set(viewControllers: [UIViewController], animated: Bool)
    }
    
    var messages: [Message] = []
    
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        messages.append(.set(viewControllers: viewControllers, animated: animated))
    }
}
