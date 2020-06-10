//
//  SessionControllerTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core
@testable import CatsDogs


class SessionControllerTests: XCTestCase {
    func test() {
        let _ = makeSut()
    }
    
    func test_check_startsTokenLoading() {
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(tokenLoader: tokenLoader)
        
        XCTAssertEqual(tokenLoader.loadCallCount, 0)
        sut.check()
        XCTAssertEqual(tokenLoader.loadCallCount, 1)
    }
    
    func test_tokenLoadingCompletionWithError_completesWithNotFound() {
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(tokenLoader: tokenLoader)
        
        var retrieved: [SessionCheckResult] = []
        sut.check { retrieved.append($0) }
        
        XCTAssertEqual(retrieved, [])
        tokenLoader.complete(with: .failure(anyError()))
        
        XCTAssertEqual(retrieved, [.notFound])
    }
    
    func test_tokenLoadingCompletionWithError_doesNotStartProfileRequest() {
        let profileLoader = ProfileLoaderSpy()
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenLoader: tokenLoader)
        
        sut.check()
        
        XCTAssertEqual(profileLoader.loadCallCount, 0)
        tokenLoader.complete(with: .failure(anyError()))
        XCTAssertEqual(profileLoader.loadCallCount, 0)
    }
    
    func test_tokenLoadingCompletionWithToken_startsProfileRequest() {
        let profileLoader = ProfileLoaderSpy()
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenLoader: tokenLoader)
        
        sut.check()
        
        XCTAssertEqual(profileLoader.loadCallCount, 0)
        tokenLoader.complete(with: .success(makeToken()))
        XCTAssertEqual(profileLoader.loadCallCount, 1)
    }
    
    func test_profileLoadCompletionWithError_completesWithInvalid() {
        let profileLoader = ProfileLoaderSpy()
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenLoader: tokenLoader)
        
        var retrieved: [SessionCheckResult] = []
        sut.check { retrieved.append($0) }
        
        tokenLoader.complete(with: .success(makeToken()))
        profileLoader.complete(with: .failure(anyError()))
        
        XCTAssertEqual(retrieved, [.invalid])
    }
    
    func test_profileLoadCompletionWithProfileInfo_completesWithExists() {
        let profileLoader = ProfileLoaderSpy()
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenLoader: tokenLoader)
        
        var retrieved: [SessionCheckResult] = []
        sut.check { retrieved.append($0) }
        
        tokenLoader.complete(with: .success(makeToken()))
        profileLoader.complete(with: .success(makeProfileInfo()))
        
        XCTAssertEqual(retrieved, [.exists])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        profileLoader: ProfileLoaderSpy = .init(),
        tokenLoader: TokenLoaderSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> SessionController
    {
        let sut = SessionController(profileLoader: profileLoader, tokenLoader: tokenLoader)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: tokenLoader, file: file, line: line)
        trackMemoryLeaks(for: profileLoader, file: file, line: line)
        
        return sut
    }
    
    private func makeToken() -> AccessToken {
        AccessToken(
            credentials: Credentials(login: "login", password: "password"),
            expirationDate: Date())
    }
    
    private func makeProfileInfo() -> ProfileInfo {
        ProfileInfo(username: "username")
    }
    
    private final class ProfileLoaderSpy: ProfileLoader {
        private var completions: [(Result<ProfileInfo, Error>) -> ()] = []
        var loadCallCount: Int { completions.count }
        
        func load(_ completion: @escaping (Result<ProfileInfo, Error>) -> ()) {
            completions.append(completion)
        }
        
        func complete(with result: Result<ProfileInfo, Error>, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
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
    
    private final class TokenLoaderSpy: TokenLoader {
        private var completions: [(Result<AccessToken, Error>) -> ()] = []
        var loadCallCount: Int { completions.count }
        
        func load(_ completion: @escaping (Result<AccessToken, Error>) -> ()) {
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
}

private extension SessionController {
    func check() {
        check({ _ in })
    }
}
