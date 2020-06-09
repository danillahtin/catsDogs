//
//  SessionControllerTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


struct AccessToken {
    
}

final class ProfileLoaderSpy {
    private(set) var loadCallCount: Int = 0
    
    func load() {
        loadCallCount += 1
    }
}

final class TokenStoreSpy {
    private var completions: [(Result<AccessToken, Error>) -> ()] = []
    var loadCallCount: Int { completions.count }
    
    func load(completion: @escaping (Result<AccessToken, Error>) -> ()) {
        completions.append(completion)
    }
    
    func complete(with result: Result<AccessToken, Error>, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        guard completions.indices.contains(index) else {
            XCTFail(
                "Completion at index \(index) not found, has only \(completions.count) completions",
                file: file,
                line: line)
            return
        }
        
        completions[index](result)
    }
}

final class SessionController {
    let profileLoader: ProfileLoaderSpy
    let tokenStore: TokenStoreSpy
    
    init(profileLoader: ProfileLoaderSpy, tokenStore: TokenStoreSpy) {
        self.profileLoader = profileLoader
        self.tokenStore = tokenStore
    }
    
    func check(_ completion: @escaping (SessionCheckResult) -> ()) {
        tokenStore.load { [profileLoader] _ in
            completion(.notFound)
        }
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
        tokenStore.complete(with: .failure(anyError()))
        
        XCTAssertEqual(retrieved, [.notFound])
    }
    
    func test_tokenLoadingCompletionWithError_doesNotStartProfileRequest() {
        let profileLoader = ProfileLoaderSpy()
        let tokenStore = TokenStoreSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenStore: tokenStore)
        
        sut.check()
        
        XCTAssertEqual(profileLoader.loadCallCount, 0)
        tokenStore.complete(with: .failure(anyError()))
        XCTAssertEqual(profileLoader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        profileLoader: ProfileLoaderSpy = .init(),
        tokenStore: TokenStoreSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> SessionController
    {
        let sut = SessionController(profileLoader: profileLoader, tokenStore: tokenStore)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: tokenStore, file: file, line: line)
        trackMemoryLeaks(for: profileLoader, file: file, line: line)
        
        return sut
    }
    
    private func anyError() -> NSError {
        NSError(domain: #file, code: 0, userInfo: nil)
    }
    
    private func makeToken() -> AccessToken {
        AccessToken()
    }
}

private extension SessionController {
    func check() {
        check({ _ in })
    }
}
