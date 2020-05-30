//
//  CatServiceTests.swift
//  CoreTests
//
//  Created by Danil Lahtin on 30.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class CatService {
    
}

class CatServiceTests: XCTestCase {
    func test_init() {
        let sut = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> CatService
    {
        let sut = CatService()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
