//
//  UserDefaultsTokenStoreTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs

class UserDefaultsTokenStore {
    func load(_ completion: @escaping (Result<AccessToken, Error>) -> ()) {
        
    }
}

class UserDefaultsTokenStoreTests: XCTestCase {
    func test_load_returnsNotFoundErrorWhenNothingSaved() {
        var retrieved: [Result<AccessToken, NSError>] = []
        makeSut().load {
            retrieved.append($0.mapError({ $0 as NSError }))
        }
        
        XCTAssertEqual(retrieved, [])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> UserDefaultsTokenStore
    {
        let sut = UserDefaultsTokenStore()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
