//
//  UserDefaultsTokenStoreTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core
@testable import CatsDogs

final class UserDefaultsTokenStore {
    private struct CodableToken: Codable {
        let login: String
        let password: String
        let expirationDate: Date
        
        init(token: AccessToken) {
            self.login = token.credentials.login
            self.password = token.credentials.password
            self.expirationDate = token.expirationDate
        }
        
        func token() -> AccessToken {
            AccessToken(credentials: Credentials(login: login, password: password),
                        expirationDate: expirationDate)
        }
    }
    
    enum Error: Swift.Error {
        case dataNotFound
    }
    
    let userDefaults: UserDefaults
    private let key = "UserDefaultsTokenStore.tokenKey"
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func save(token: AccessToken, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
        do {
            let data = try JSONEncoder().encode(CodableToken(token: token))
            userDefaults.set(data, forKey: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func load(_ completion: @escaping (Result<AccessToken, Swift.Error>) -> ()) {
        guard let data = userDefaults.data(forKey: key) else {
            return completion(.failure(Error.dataNotFound))
        }
        
        do {
            let token = try JSONDecoder().decode(CodableToken.self, from: data)
            completion(.success(token.token()))
        } catch {
            completion(.failure(error))
        }
    }
}

class UserDefaultsTokenStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
    }
    
    func test_load_returnsErrorWhenNothingSaved() {
        var retrieved: [Result<AccessToken, NSError>] = []
        makeSut().load {
            retrieved.append($0.mapError({ $0 as NSError }))
        }
        
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertThrowsError(try retrieved.first?.get())
    }
    
    func test_load_returnsSavedToken() {
        let token = makeToken()
        
        let expSave = expectation(description: "Wait for save")
        makeSut().save(token: token, completion: { _ in
            expSave.fulfill()
        })
        
        wait(for: [expSave], timeout: 5.0)
        
        let expLoad = expectation(description: "Wait for load")
        var retrieved: [Result<AccessToken, NSError>] = []
        makeSut().load {
            retrieved.append($0.mapError({ $0 as NSError }))
            expLoad.fulfill()
        }
        
        wait(for: [expLoad], timeout: 5.0)
        
        XCTAssertEqual(retrieved, [.success(token)])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> UserDefaultsTokenStore
    {
        let sut = UserDefaultsTokenStore(userDefaults: userDefaults)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
    
    private func makeToken() -> AccessToken {
        AccessToken(
            credentials: Credentials(login: "login", password: "password"),
            expirationDate: Date(timeIntervalSince1970: 0))
    }
}
