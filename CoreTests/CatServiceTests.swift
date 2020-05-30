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
    typealias Observer = ([Cat]) -> ()
    
    let loader: CatsLoader
    private var observers: [Observer] = []
    private var cats: [Cat]? {
        didSet {
            guard let cats = cats else {
                return
            }
            
            observers.forEach({ $0(cats) })
        }
    }
    
    init(loader: CatsLoader) {
        self.loader = loader
    }
    
    func subscribe(onNext: @escaping ([Cat]) -> ()) {
        observers.append(onNext)
        
        if let cats = cats {
            onNext(cats)
        } else {
            loader.load { [weak self] in self?.cats = $0 }
        }
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
        
        let observer0 = CatsObserver(sut: sut)
        let observer1 = CatsObserver(sut: sut)
        
        XCTAssertEqual(observer0.retrieved, [])
        XCTAssertEqual(observer1.retrieved, [])
        
        let cats = [Cat(), Cat(), Cat()]
        loader.complete(with: cats)
        
        XCTAssertEqual(observer0.retrieved, [cats])
        XCTAssertEqual(observer1.retrieved, [cats])
    }
    
    func test_subscribeAfterSuccessfulLoad_notifiesWithPreviouslyLoadedCats() {
        let (sut, loader) = makeSut()
        
        sut.subscribe(onNext: { _ in })
        let cats = [Cat(), Cat(), Cat()]
        loader.complete(with: cats)
        
        XCTAssertEqual(CatsObserver(sut: sut).retrieved, [cats])
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
    
    private final class CatsObserver {
        private(set) var retrieved: [[Cat]] = []
        
        init(sut: CatService) {
            sut.subscribe(onNext: { [weak self] in
                self?.retrieved.append($0)
            })
        }
    }
}
