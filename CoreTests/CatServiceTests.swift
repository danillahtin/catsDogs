//
//  CatServiceTests.swift
//  CoreTests
//
//  Created by Danil Lahtin on 30.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


struct Cat: Equatable {
    
}

final class CatsLoader {
    private var completions: [([Cat]) -> ()] = []
    
    var loadCallCount: Int { completions.count }
    
    func load(_ completion: @escaping ([Cat]) -> ()) {
        completions.append(completion)
    }
    
    func complete(
        with cats: [Cat],
        at index: Int = 0,
        file: StaticString = #file,
        line: UInt = #line)
    {
        guard completions.indices.contains(index) else {
            XCTFail(
                "Completion at index \(index) not found, has only \(completions.count) completions",
                file: file,
                line: line)
            return
        }
        
        completions[index](cats)
    }
}

final class CatService {
    let loader: CatsLoader
    
    init(loader: CatsLoader) {
        self.loader = loader
    }
    
    func subscribe(onNext: @escaping ([Cat]) -> ()) {
        loader.load(onNext)
    }
}

class CatServiceTests: XCTestCase {
    func test_subscribe_loadsCats() {
        let (sut, loader) = makeSut()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        sut.subscribe(onNext: { _ in })
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_loadCompletionWithCats_notifies() {
        let (sut, loader) = makeSut()
        
        var retrievedCats: [[Cat]] = []
        sut.subscribe(onNext: {
            retrievedCats.append($0)
        })
        
        XCTAssertEqual(retrievedCats, [])
        
        let cats = [Cat(), Cat(), Cat()]
        loader.complete(with: cats)
        
        XCTAssertEqual(retrievedCats, [cats])
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
