//
//  CatServiceTests.swift
//  CoreTests
//
//  Created by Danil Lahtin on 30.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class CatsLoader {
    var loadCallCount = 0
    
    func load() {
        loadCallCount += 1
    }
}

final class CatService {
    let loader: CatsLoader
    
    init(loader: CatsLoader) {
        self.loader = loader
    }
    
    func subscribe() {
        loader.load()
    }
}

class CatServiceTests: XCTestCase {
    func test_subscribe_loadsCats() {
        let (sut, loader) = makeSut()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        sut.subscribe()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: CatService, loader: CatsLoader)
    {
        let loader = CatsLoader()
        let sut = CatService(loader: loader)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return (sut, loader)
    }
}
