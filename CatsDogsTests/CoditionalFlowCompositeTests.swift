//
//  CoditionalFlowCompositeTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


class ConditionalFlowComposite: Flow {
    let primary: Flow
    
    init(primary: Flow) {
        self.primary = primary
    }
    
    func start() {
        primary.start()
    }
}

class CoditionalFlowCompositeTests: XCTestCase {
    func test_init_doesNotStartComponents() {
        let primary = FlowSpy()
        let secondary = FlowSpy()
        _ = makeSut(primary: primary, secondary: secondary)
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 0)
    }
    
    func test_start_startsPrimaryWhenConditionIsTrue() {
        let primary = FlowSpy()
        let secondary = FlowSpy()
        let sut = makeSut(primary: primary, secondary: secondary, condition: true)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 1)
        XCTAssertEqual(secondary.startedCount, 0)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 2)
        XCTAssertEqual(secondary.startedCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        primary: FlowSpy = .init(),
        secondary: FlowSpy = .init(),
        condition: Bool = true,
        file: StaticString = #file,
        line: UInt = #line) -> Flow
    {
        let sut = ConditionalFlowComposite(primary: primary)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: primary, file: file, line: line)
        trackMemoryLeaks(for: secondary, file: file, line: line)
        
        return sut
    }
}
