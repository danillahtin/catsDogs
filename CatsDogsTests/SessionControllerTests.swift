//
//  SessionControllerTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class TokenStoreSpy {
    private(set) var loadCallCount = 0
    
    func load() {
        loadCallCount += 1
    }
}

final class SessionController {
    let tokenStore: TokenStoreSpy
    
    init(tokenStore: TokenStoreSpy) {
        self.tokenStore = tokenStore
    }
    
    func check() {
        tokenStore.load()
    }
}

class SessionControllerTests: XCTestCase {
    func test() {
        let _ = makeSut()
    }
    
    func test_check_startsTokenLoading() {
        let tokenStore = TokenStoreSpy()
        let sut = makeSut(tokenStore: tokenStore)
        
        XCTAssertEqual(tokenStore.loadCallCount, 0)
        sut.check()
        XCTAssertEqual(tokenStore.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        tokenStore: TokenStoreSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> SessionController
    {
        let sut = SessionController(tokenStore: tokenStore)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: tokenStore, file: file, line: line)
        
        return sut
    }
}
