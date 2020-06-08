//
//  CoditionalFlowCompositeTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


class ConditionalFlowComposite {}

class CoditionalFlowCompositeTests: XCTestCase {
    func test() {
        let sut = makeSut()
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> ConditionalFlowComposite
    {
        let sut = ConditionalFlowComposite()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}
