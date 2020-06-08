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
    func test_init_doesNotStartComponents() {
        let primary = FlowSpy()
        let secondary = FlowSpy()
        _ = makeSut(primary: primary, secondary: secondary)
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        primary: FlowSpy = .init(),
        secondary: FlowSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> ConditionalFlowComposite
    {
        let sut = ConditionalFlowComposite()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: primary, file: file, line: line)
        trackMemoryLeaks(for: secondary, file: file, line: line)
        
        return sut
    }
}
