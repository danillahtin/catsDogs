//
//  AppStartFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class AppStartFlow {}


class AppStartFlowTests: XCTestCase {
    func test() {
        let sut = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> AppStartFlow
    {
        let sut = AppStartFlow()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
