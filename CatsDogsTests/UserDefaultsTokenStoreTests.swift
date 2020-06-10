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


class UserDefaultsTokenStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
    }
    
    func test_load_returnsErrorWhenNothingSaved() {
        let loadResult = load()
        
        XCTAssertEqual(loadResult.count, 1)
        XCTAssertThrowsError(try loadResult.first?.get())
    }
    
    func test_load_returnsSavedToken() {
        let token = makeToken()
        
        let saveResult = save(token: token)
        XCTAssertEqual(saveResult.count, 1)
        XCTAssertNoThrow(try saveResult.first?.get())
        
        XCTAssertEqual(load(), [.success(token)])
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
    
    private func save(token: AccessToken) -> [Result<Void, NSError>] {
        var retrieved: [Result<Void, NSError>] = []
        
        let expSave = expectation(description: "Wait for save")
        makeSut().save(token: token, completion: {
            retrieved.append($0.mapError({ $0 as NSError }))
            expSave.fulfill()
        })
        
        wait(for: [expSave], timeout: 5.0)
        
        return retrieved
    }
    
    private func load() -> [Result<AccessToken, NSError>] {
        let expLoad = expectation(description: "Wait for load")
        var retrieved: [Result<AccessToken, NSError>] = []
        makeSut().load {
            retrieved.append($0.mapError({ $0 as NSError }))
            expLoad.fulfill()
        }
        
        wait(for: [expLoad], timeout: 5.0)
        
        return retrieved
    }
}
