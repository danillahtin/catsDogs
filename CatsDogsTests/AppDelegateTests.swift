//
//  AppDelegateTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


class AppDelegateTests: XCTestCase {
    func test() {
        let sut = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> AppDelegate
    {
        let sut = AppDelegate()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
