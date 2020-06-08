//
//  FlowSpy.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

@testable import CatsDogs


final class FlowSpy: Flow {
    var startedCount = 0
    
    func start() {
        startedCount += 1
    }
}
