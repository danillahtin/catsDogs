//
//  SessionControllerTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs

protocol ProfileLoader {
    func load(_ completion: @escaping (Result<ProfileInfo, Error>) -> ())
}



final class TokenLoaderSpy {
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
    let profileLoader: ProfileLoader
    let tokenLoader: TokenLoaderSpy
    
    init(profileLoader: ProfileLoader, tokenLoader: TokenLoaderSpy) {
        self.profileLoader = profileLoader
        self.tokenLoader = tokenLoader
    }
    
    func check(_ completion: @escaping (SessionCheckResult) -> ()) {
        tokenLoader.load { [profileLoader] in
            switch $0 {
            case .success:
                profileLoader.load {
                    switch $0 {
                    case .success:
                        completion(.exists)
                    case .failure:
                        completion(.invalid)
                    }
                }
            case .failure:
                completion(.notFound)
            }
        }
    }
}

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
    
    private func anyError() -> NSError {
        NSError(domain: #file, code: 0, userInfo: nil)
    }
    
    private func makeToken() -> AccessToken {
        AccessToken()
    }
    
    private func makeProfileInfo() -> ProfileInfo {
        ProfileInfo()
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
}

private extension SessionController {
    func check() {
        check({ _ in })
    }
}
