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
    
    func test_profileLoadCompletionWithProfileInfo_updatesProfileInfo() {
        let profileLoader = ProfileLoaderSpy()
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenLoader: tokenLoader)
        let profileInfo = makeProfileInfo()
        
        sut.check()
        tokenLoader.complete(with: .success(makeToken()))
        
        XCTAssertEqual(sut.profileInfo, nil)
        profileLoader.complete(with: .success(profileInfo))
        
        XCTAssertEqual(sut.profileInfo, profileInfo)
    }
    
    func test_startWithCredentials_requestsAuthorizationWithCredentials() {
        let authorizeApi = AuthorizeApiSpy()
        let sut = makeSut(authorizeApi: authorizeApi)
        
        XCTAssertEqual(authorizeApi.credentials, [])
        sut.start(credentials: makeCredentials(login: "login"))
        
        XCTAssertEqual(authorizeApi.credentials, [
            makeCredentials(login: "login"),
        ])
        
        sut.start(credentials: makeCredentials(login: "another login"))
        
        XCTAssertEqual(authorizeApi.credentials, [
            makeCredentials(login: "login"),
            makeCredentials(login: "another login"),
        ])
    }
    
    func test_authorizationCompletionWithError_completesWithError() {
        let authorizeApi = AuthorizeApiSpy()
        let sut = makeSut(authorizeApi: authorizeApi)
        let error = anyError()
        
        var retrieved: [Result<EquatableVoid, NSError>] = []
        sut.start(credentials: makeCredentials()) {
            retrieved.append(toEquatable($0))
        }
        
        XCTAssertEqual(retrieved, [])
        authorizeApi.complete(with: .failure(error))
        
        XCTAssertEqual(retrieved, [.failure(error)])
    }
    
    func test_authorizationCompletionWithError_doesNotSaveToken() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver)
        
        sut.start(credentials: makeCredentials())
        authorizeApi.complete(with: .failure(anyError()))
        
        XCTAssertEqual(tokenSaver.tokens, [])
    }
    
    func test_authorizationCompletionWithSuccess_savesToken() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver)
        let token = makeToken()
        
        sut.start(credentials: makeCredentials())
        
        XCTAssertEqual(tokenSaver.tokens, [])
        authorizeApi.complete(with: .success(token))
        
        XCTAssertEqual(tokenSaver.tokens, [token])
    }
    
    func test_tokenSaveCompletionWithError_completesWithError() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver)
        let error = anyError()
        
        var retrieved: [Result<EquatableVoid, NSError>] = []
        sut.start(credentials: makeCredentials()) {
            retrieved.append(toEquatable($0))
        }
        
        authorizeApi.complete(with: .success(makeToken()))
        
        XCTAssertEqual(retrieved, [])
        tokenSaver.complete(with: .failure(error))
        
        XCTAssertEqual(retrieved, [.failure(error)])
    }
    
    func test_tokenSaveCompletionWithError_doesNotLoadProfile() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        let error = anyError()
        
        sut.start(credentials: makeCredentials())
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .failure(error))
        
        XCTAssertEqual(profileLoader.loadCallCount, 0)
    }
    
    func test_tokenSaveCompletionWithSuccess_loadsProfile() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        
        sut.start(credentials: makeCredentials())
        authorizeApi.complete(with: .success(makeToken()))
        
        XCTAssertEqual(profileLoader.loadCallCount, 0)
        tokenSaver.complete(with: .success(()))
        XCTAssertEqual(profileLoader.loadCallCount, 1)
    }
    
    func test_completeLoadProfileOnAuthorizeWithError_completesWithError() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        let error = anyError()
        
        var retrieved: [Result<EquatableVoid, NSError>] = []
        sut.start(credentials: makeCredentials()) {
            retrieved.append(toEquatable($0))
        }
        
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .success(()))
        
        XCTAssertEqual(retrieved, [])
        profileLoader.complete(with: .failure(error))
        
        XCTAssertEqual(retrieved, [.failure(error)])
    }
    
    func test_completeLoadProfileOnAuthorizeWithError_doesNotStoreProfileInfo() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        let error = anyError()

        sut.start(credentials: makeCredentials())
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .success(()))
        
        XCTAssertEqual(sut.profileInfo, nil)
        profileLoader.complete(with: .failure(error))
        
        XCTAssertEqual(sut.profileInfo, nil)
    }
    
    func test_completeLoadProfileOnAuthorizeWithSuccess_storesProfileInfo() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        let profileInfo = makeProfileInfo()
        
        sut.start(credentials: makeCredentials())
        
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .success(()))
        
        XCTAssertEqual(sut.profileInfo, nil)
        profileLoader.complete(with: .success(profileInfo))
        
        XCTAssertEqual(sut.profileInfo, profileInfo)
    }
    
    func test_completeLoadProfileOnAuthorizeWithSuccess_completesWithSuccess() {
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        let profileInfo = makeProfileInfo()
        
        var retrieved: [Result<EquatableVoid, NSError>] = []
        sut.start(credentials: makeCredentials()) {
            retrieved.append(toEquatable($0))
        }
        
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .success(()))
        
        XCTAssertEqual(retrieved, [])
        profileLoader.complete(with: .success(profileInfo))
        
        XCTAssertEqual(retrieved, [.success(EquatableVoid())])
    }
    
    func test_profileInfoChanged_notifiesWithProfileState() {
        let profileLoader = ProfileLoaderSpy()
        let tokenLoader = TokenLoaderSpy()
        let sut = makeSut(profileLoader: profileLoader, tokenLoader: tokenLoader)
        
        sut.check()
        
        var retrieved: [ProfileState] = []
        sut.didUpdateProfileState = { retrieved.append($0) }
        
        tokenLoader.complete(with: .success(makeToken()))
        
        XCTAssertEqual(retrieved, [])
        
        profileLoader.complete(with: .success(makeProfileInfo(username: "username")))
        
        XCTAssertEqual(retrieved, [.authorized("username")])
        
        profileLoader.complete(with: .success(makeProfileInfo(username: "another username")))
        
        XCTAssertEqual(retrieved, [
            .authorized("username"),
            .authorized("another username")
        ])
    }
    
    func test_logout_requestsLogout() {
        let logoutApi = LogoutApiSpy()
        let sut = makeSut(logoutApi: logoutApi)
        
        XCTAssertEqual(logoutApi.logoutCallCount, 0)
        sut.logout()
        XCTAssertEqual(logoutApi.logoutCallCount, 1)
    }
    
    func test_logoutCompletionWithError_completes() {
        let logoutApi = LogoutApiSpy()
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, logoutApi: logoutApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        
        sut.start(credentials: makeCredentials())
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .success(()))
        profileLoader.complete(with: .success(makeProfileInfo()))
        
        var completedCount = 0
        sut.logout { completedCount += 1 }
        
        XCTAssertEqual(completedCount, 0)
        logoutApi.complete(with: .failure(anyError()))
        
        XCTAssertEqual(completedCount, 1)
        XCTAssertEqual(sut.profileInfo, nil)
    }
    
    func test_logoutCompletionWithSuccess_completes() {
        let logoutApi = LogoutApiSpy()
        let authorizeApi = AuthorizeApiSpy()
        let tokenSaver = TokenSaverSpy()
        let profileLoader = ProfileLoaderSpy()
        let sut = makeSut(authorizeApi: authorizeApi, logoutApi: logoutApi, tokenSaver: tokenSaver, profileLoader: profileLoader)
        
        sut.start(credentials: makeCredentials())
        authorizeApi.complete(with: .success(makeToken()))
        tokenSaver.complete(with: .success(()))
        profileLoader.complete(with: .success(makeProfileInfo()))
        
        var completedCount = 0
        sut.logout { completedCount += 1 }
        
        XCTAssertEqual(completedCount, 0)
        logoutApi.complete(with: .success(()))
        
        XCTAssertEqual(completedCount, 1)
        XCTAssertEqual(sut.profileInfo, nil)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        authorizeApi: AuthorizeApiSpy = .init(),
        logoutApi: LogoutApiSpy = .init(),
        tokenSaver: TokenSaverSpy = .init(),
        profileLoader: ProfileLoaderSpy = .init(),
        tokenLoader: TokenLoaderSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> SessionController
    {
        let sut = SessionController(
            authorizeApi: authorizeApi,
            logoutApi: logoutApi,
            tokenSaver: tokenSaver,
            profileLoader: profileLoader,
            tokenLoader: tokenLoader)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: authorizeApi, file: file, line: line)
        trackMemoryLeaks(for: logoutApi, file: file, line: line)
        trackMemoryLeaks(for: tokenSaver, file: file, line: line)
        trackMemoryLeaks(for: tokenLoader, file: file, line: line)
        trackMemoryLeaks(for: profileLoader, file: file, line: line)
        
        return sut
    }
    
    private func makeToken() -> AccessToken {
        AccessToken(
            credentials: makeCredentials(),
            expirationDate: Date())
    }
    
    private func makeProfileInfo(username: String = "some username") -> ProfileInfo {
        ProfileInfo(username: username)
    }
    
    private func makeCredentials(login: String = "some login") -> Credentials {
        Credentials(login: login, password: "any password")
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
    
    private final class AuthorizeApiSpy: AuthorizeApi {
        typealias Completion = (Result<AccessToken, Error>) -> ()
        typealias Message = (credentials: Credentials, completion: Completion)
        private var messages: [Message] = []
        
        var completions: [(Result<AccessToken, Error>) -> ()] { messages.map({ $0.completion }) }
        var credentials: [Credentials] { messages.map({ $0.credentials }) }
        
        func authorize(with credentials: Credentials, _ completion: @escaping (Result<AccessToken, Error>) -> ()) {
            self.messages.append((credentials, completion))
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
    
    private final class TokenSaverSpy: TokenSaver {
        typealias Completion = (Result<Void, Error>) -> ()
        typealias Message = (token: AccessToken, completion: Completion)
        private var messages: [Message] = []
        
        var completions: [(Result<Void, Error>) -> ()] { messages.map({ $0.completion }) }
        var tokens: [AccessToken] { messages.map({ $0.token }) }
        
        func save(token: AccessToken, completion: @escaping (Result<Void, Error>) -> ()) {
            messages.append((token, completion))
        }
        
        func complete(with result: Result<Void, Error>, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
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
    
    private final class LogoutApiSpy: LogoutApi {
        typealias Completion = (Result<Void, Error>) -> ()
        private var completions: [Completion] = []
        
        var logoutCallCount: Int { completions.count }
        
        func logout(_ completion: @escaping (Result<Void, Error>) -> ()) {
            completions.append(completion)
        }
        
        func complete(with result: Result<Void, Error>, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
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
    
    func start(credentials: Credentials) {
        start(credentials: credentials) { _ in }
    }
    
    func logout() {
        logout {}
    }
}


private struct EquatableVoid: Equatable {}

private func toEquatable(_ result: Result<Void, Error>) -> Result<EquatableVoid, NSError> {
    result.map(EquatableVoid.init).mapError({ $0 as NSError })
}
