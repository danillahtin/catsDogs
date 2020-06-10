//
//  UserDefaultsTokenStoreTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest

class UserDefaultsTokenStore {}

class UserDefaultsTokenStoreTests: XCTestCase {
    func test() {
        let _ = makeSut()
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
