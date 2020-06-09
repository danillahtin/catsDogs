//
//  XCTestCase+SharedHelpers.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest

extension XCTestCase {
    func anyError() -> NSError {
        NSError(domain: String(describing: type(of: self)), code: 0, userInfo: nil)
    }
}
