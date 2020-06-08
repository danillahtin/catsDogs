//
//  MainFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class MainFlow {}


class MainFlowTests: XCTestCase {
    func test() {
        let sut = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> MainFlow
    {
        let sut = MainFlow()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
