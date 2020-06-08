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
    let secondary: Flow
    let condition: () -> Bool
    
    init(primary: Flow, secondary: Flow, condition: @escaping () -> Bool) {
        self.primary = primary
        self.secondary = secondary
        self.condition = condition
    }
    
    func start() {
        let flow = condition() ? primary : secondary
        
        flow.start()
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
        let sut = makeSut(primary: primary,
                          secondary: secondary,
                          condition: alwaysTrue)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 1)
        XCTAssertEqual(secondary.startedCount, 0)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 2)
        XCTAssertEqual(secondary.startedCount, 0)
    }
    
    func test_start_startsSecondaryWhenConditionIsFalse() {
        let primary = FlowSpy()
        let secondary = FlowSpy()
        let sut = makeSut(primary: primary,
                          secondary: secondary,
                          condition: alwaysFalse)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 1)
        
        sut.start()
        
        XCTAssertEqual(primary.startedCount, 0)
        XCTAssertEqual(secondary.startedCount, 2)
    }
    
    func test_start_startsAnotherFlowAfterConditionHasChanged() {
        let primary = FlowSpy()
        let secondary = FlowSpy()
        
        var condition = true
        let sut = makeSut(
            primary: primary,
            secondary: secondary,
            condition: { condition })
        
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
        primary: FlowSpy = .init(),
        secondary: FlowSpy = .init(),
        condition: @escaping () -> Bool = { true },
        file: StaticString = #file,
        line: UInt = #line) -> Flow
    {
        let sut = ConditionalFlowComposite(primary: primary, secondary: secondary, condition: condition)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: primary, file: file, line: line)
        trackMemoryLeaks(for: secondary, file: file, line: line)
        
        return sut
    }
    
    private func alwaysTrue() -> Bool {
        true
    }
    
    private func alwaysFalse() -> Bool {
        false
    }
}
