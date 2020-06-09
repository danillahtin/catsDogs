//
//  PushAuthFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class PushAuthFlow {}

class PushAuthFlowTests: XCTestCase {
    func test() {
        let sut = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> PushAuthFlow
    {
        let sut = PushAuthFlow()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
