//
//  XCTestCase+MemoryLeakTracking.swift
//  iOSTests
//
//  Created by Danil Lahtin on 15.03.2020.
//

import XCTest


extension XCTestCase {
    func trackMemoryLeaks(for object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object,
                         "Object \(String(describing: object)) should have been deallocated. Potential memory leak",
                         file: file,
                         line: line)
        }
    }
}
