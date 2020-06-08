//
//  CoditionalFlowCompositeTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


class CoditionalFlowCompositeTests: XCTestCase {
    func test_init_doesNotStartComponents() {
        let (_, primary, secondary) = makeSut()
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 0)
    }
    
    func test_start_startsPrimaryWhenConditionIsTrue() {
        let (sut, primary, secondary) = makeSut(condition: alwaysTrue)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 1)
        XCTAssertEqual(secondary.startedCount, 0)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 2)
        XCTAssertEqual(secondary.startedCount, 0)
    }
    
    func test_start_startsSecondaryWhenConditionIsFalse() {
        let (sut, primary, secondary) = makeSut(condition: alwaysFalse)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 1)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 2)
    }
    
    func test_start_startsAnotherFlowAfterConditionHasChanged() {
        var condition = true
        let (sut, primary, secondary) = makeSut(condition: { condition })
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 1)
        XCTAssertEqual(secondary.startedCount, 0)
        
        condition = false
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 1)
        XCTAssertEqual(secondary.startedCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        condition: @escaping () -> Bool = { true },
        file: StaticString = #file,
        line: UInt = #line) -> (sut: Flow, primary: FlowSpy, secondary: FlowSpy)
    {
        let primary = FlowSpy()
        let secondary = FlowSpy()
        let sut = ConditionalFlowComposite(primary: primary, secondary: secondary, condition: condition)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: primary, file: file, line: line)
        trackMemoryLeaks(for: secondary, file: file, line: line)
        
        return (sut, primary, secondary)
    }
    
    private func alwaysTrue() -> Bool {
        true
    }
    
    private func alwaysFalse() -> Bool {
        false
    }
}
