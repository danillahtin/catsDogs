//
//  SessionControllerTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class SessionController {}

class SessionControllerTests: XCTestCase {
    func test() {
        let _ = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> SessionController
    {
        let sut = SessionController()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
