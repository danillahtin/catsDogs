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
    func test_applicationDidFinishLaunchingWithOptions_startsFlow() {
        let (sut, flow) = makeSut()
        
        XCTAssertEqual(flow.startedCount, 0)
        _ = sut.application?(.shared, didFinishLaunchingWithOptions: nil)
        
        XCTAssertEqual(flow.startedCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: UIApplicationDelegate, flow: FlowSpy)
    {
        let sut = AppDelegate()
        let flow = FlowSpy()
        
        sut.flow = flow
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: flow, file: file, line: line)
        
        return (sut, flow)
    }
}
