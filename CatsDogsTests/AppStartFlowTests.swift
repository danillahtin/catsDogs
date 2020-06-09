//
//  AppStartFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest

final class SessionCheckingSpy {
    private(set) var requestsCount = 0
    
    func check() {
        requestsCount += 1
    }
}

final class AppStartFlow {
    let sessionChecking: SessionCheckingSpy
    
    init(sessionChecking: SessionCheckingSpy) {
        self.sessionChecking = sessionChecking
    }
    
    func start() {
        sessionChecking.check()
    }
}


class AppStartFlowTests: XCTestCase {
    func test_start_startsSessionCheck() {
        let sessionChecking = SessionCheckingSpy()
        let sut = makeSut(sessionChecking: sessionChecking)
        
        XCTAssertEqual(sessionChecking.requestsCount, 0)
        sut.start()
        
        XCTAssertEqual(sessionChecking.requestsCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        sessionChecking: SessionCheckingSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> AppStartFlow
    {
        let sut = AppStartFlow(sessionChecking: sessionChecking)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: sessionChecking, file: file, line: line)
        
        return sut
    }
}
