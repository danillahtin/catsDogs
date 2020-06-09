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
        let (sut, _, _) = makeSut(sessionChecking: sessionChecking)
        
        XCTAssertEqual(sessionChecking.requestsCount, 0)
        sut.start()
        
        XCTAssertEqual(sessionChecking.requestsCount, 1)
    }
    
    func test_start_doesNotStartFlows() {
        let (sut, main, auth) = makeSut()

        sut.start()
        
        XCTAssertEqual(main.startedCount, 0)
        XCTAssertEqual(auth.startedCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        sessionChecking: SessionCheckingSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> (sut: AppStartFlow, main: FlowSpy, auth: FlowSpy)
    {
        let main = FlowSpy()
        let auth = FlowSpy()
        let sut = AppStartFlow(sessionChecking: sessionChecking)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: main, file: file, line: line)
        trackMemoryLeaks(for: auth, file: file, line: line)
        trackMemoryLeaks(for: sessionChecking, file: file, line: line)
        
        return (sut, main, auth)
    }
}
