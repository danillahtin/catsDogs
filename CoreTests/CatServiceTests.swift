//
//  CatServiceTests.swift
//  CoreTests
//
//  Created by Danil Lahtin on 30.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


struct Cat: Equatable {
    let id: UUID
}

final class CatsLoader {
    private var completions: [(Result<[Cat], Error>) -> ()] = []
    
    var loadCallCount: Int { completions.count }
    
    func load(_ completion: @escaping (Result<[Cat], Error>) -> ()) {
        completions.append(completion)
    }
    
    func complete(
        with cats: [Cat],
        at index: Int = 0,
        file: StaticString = #file,
        line: UInt = #line)
    {
        complete(with: .success(cats), at: index, file: file, line: line)
    }
    
    func complete(
        with error: Error,
        at index: Int = 0,
        file: StaticString = #file,
        line: UInt = #line)
    {
        complete(with: .failure(error), at: index, file: file, line: line)
    }
    
    func complete(
        with result: Result<[Cat], Error>,
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
        
        completions[index](result)
    }
}

final class CatService {
    typealias Observer<T> = (T) -> ()
    
    private let loader: CatsLoader
    private var catObservers: [Observer<[Cat]>] = []
    private var errorObservers: [Observer<Error>] = []
    
    private var cats: [Cat]?
    
    init(loader: CatsLoader) {
        self.loader = loader
    }
    
    func subscribe(onNext: @escaping ([Cat]) -> ()) {
        catObservers.append(onNext)
        
        if let cats = cats {
            return onNext(cats)
        }
        
        loader.load { [weak self] in
            self?.handle(loadResult: $0)
        }
    }
    
    func subscribe(onError: @escaping (Error) -> ()) {
        errorObservers.append(onError)
    }
    
    private func handle(loadResult: Result<[Cat], Error>) {
        switch loadResult {
        case .success(let cats):
            self.cats = cats
            notify(with: cats)
        case .failure(let error):
            notify(with: error)
        }
    }
    
    private func notify(with error: Error) {
        errorObservers.forEach({ $0(error) })
    }
    
    private func notify(with cats: [Cat]) {
        catObservers.forEach({ $0(cats) })
    }
}

class CatServiceTests: XCTestCase {
    func test_subscribe_loadsCats() {
        let (sut, loader) = makeSut()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        sut.subscribe(onNext: { _ in })
        
        XCTAssertEqual(loader.loadCallCount, 1)
        sut.subscribe(onNext: { _ in })
        
        XCTAssertEqual(loader.loadCallCount, 2)
        loader.complete(with: [], at: 1)
        sut.subscribe(onNext: { _ in })
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    func test_loadCompletionWithCats_notifies() {
        let (sut, loader) = makeSut()
        
        let observer0 = CatsObserver(sut: sut)
        let observer1 = CatsObserver(sut: sut)
        
        XCTAssertEqual(observer0.retrieved, [])
        XCTAssertEqual(observer1.retrieved, [])
        
        let cats = makeCats()
        loader.complete(with: cats)
        
        XCTAssertEqual(observer0.retrieved, [cats])
        XCTAssertEqual(observer1.retrieved, [cats])
    }
    
    func test_subscribeAfterSuccessfulLoad_notifiesWithPreviouslyLoadedCats() {
        let (sut, loader) = makeSut()
        
        sut.subscribe(onNext: { _ in })
        let cats = makeCats()
        loader.complete(with: cats)
        
        XCTAssertEqual(CatsObserver(sut: sut).retrieved, [cats])
    }
    
    func test_loadCompletionWithCats_doesNotNotifyError() {
        let (sut, loader) = makeSut()
        
        sut.subscribe(onNext: { _ in })
        loader.complete(with: [])
        
        XCTAssertEqual(ErrorObserver(sut: sut).retrieved, [])
    }
    
    func test_loadCompletionWithError_notifiesError() {
        let (sut, loader) = makeSut()
        let error = anyError()
        let errorObserver = ErrorObserver(sut: sut)
        
        sut.subscribe(onNext: { _ in })
        loader.complete(with: error, at: 0)
        
        XCTAssertEqual(errorObserver.retrieved, [error])
        XCTAssertEqual(ErrorObserver(sut: sut).retrieved, [])
        
        sut.subscribe(onNext: { _ in })
        loader.complete(with: error, at: 1)
        
        XCTAssertEqual(errorObserver.retrieved, [error, error])
        XCTAssertEqual(ErrorObserver(sut: sut).retrieved, [])
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
    
    private func makeCats() -> [Cat] {
        [Cat(id: UUID()), Cat(id: UUID()), Cat(id: UUID())]
    }
    
    private func anyError() -> NSError {
        NSError(domain: "TestDomain", code: 0, userInfo: nil)
    }
    
    private final class CatsObserver {
        private(set) var retrieved: [[Cat]] = []
        
        init(sut: CatService) {
            sut.subscribe(onNext: { [weak self] in
                self?.retrieved.append($0)
            })
        }
    }
    
    private final class ErrorObserver {
        private(set) var retrieved: [NSError] = []
        
        init(sut: CatService) {
            sut.subscribe(onError: { [weak self] in
                self?.retrieved.append($0 as NSError)
            })
        }
    }
}
