//
//  SessionControllerTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


final class TokenStoreSpy {
    private var completions: [(Error) -> ()] = []
    var loadCallCount: Int { completions.count }
    
    func load(completion: @escaping (Error) -> ()) {
        completions.append(completion)
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

final class SessionController {
    let tokenStore: TokenStoreSpy
    
    init(tokenStore: TokenStoreSpy) {
        self.tokenStore = tokenStore
    }
    
    func check(_ completion: @escaping (SessionCheckResult) -> ()) {
        tokenStore.load { _ in completion(.notFound) }
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
    
    func test_tokenLoadingCompletionWithError_completesWithNotFound() {
        let tokenStore = TokenStoreSpy()
        let sut = makeSut(tokenStore: tokenStore)
        
        var retrieved: [SessionCheckResult] = []
        sut.check { retrieved.append($0) }
        
        XCTAssertEqual(retrieved, [])
        tokenStore.complete(with: anyError())
        
        XCTAssertEqual(retrieved, [.notFound])
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
    
    private func anyError() -> NSError {
        NSError(domain: #file, code: 0, userInfo: nil)
    }
}

private extension SessionController {
    func check() {
        check({ _ in })
    }
}
