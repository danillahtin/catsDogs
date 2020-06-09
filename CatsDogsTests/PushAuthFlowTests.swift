//
//  PushAuthFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


final class PushAuthFlow {}

class PushAuthFlowTests: XCTestCase {
    func test_init_doesNotSet() {
        let (_, navigationController) = makeSut()

        XCTAssertEqual(navigationController.messages, [])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: PushAuthFlow, navigationController: NavigationControllerSpy)
    {
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = PushAuthFlow()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: navigationControllerSpy, file: file, line: line)
        
        return (sut, navigationControllerSpy)
    }
}
