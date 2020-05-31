//
//  CatServiceTests.swift
//  CoreTests
//
//  Created by Danil Lahtin on 30.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core

private typealias Service = LoadingStorage<CatServiceTests.CatsLoaderSpy>

class CatServiceTests: XCTestCase {
    
    func test_subscribe_loadsCats() {
        let (sut, loader) = makeSut()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        sut.subscribeCats()
        
        XCTAssertEqual(loader.loadCallCount, 1)
        sut.subscribeCats()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        loader.complete(with: [], at: 1)
        sut.subscribeCats()
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    func test_loadCompletionWithCats_notifies() {
        let (sut, loader) = makeSut()
        
        let observer0 = SpyObserver<[Cat]>(sut: sut)
        let observer1 = SpyObserver<[Cat]>(sut: sut)
        
        XCTAssertEqual(observer0.retrieved, [])
        XCTAssertEqual(observer1.retrieved, [])
        
        let cats = makeCats()
        loader.complete(with: cats)
        
        XCTAssertEqual(observer0.retrieved, [cats])
        XCTAssertEqual(observer1.retrieved, [cats])
    }
    
    func test_subscribeAfterSuccessfulLoad_notifiesWithPreviouslyLoadedCats() {
        let (sut, loader) = makeSut()
        
        sut.subscribeCats()
        let cats = makeCats()
        loader.complete(with: cats)
        
        XCTAssertEqual(SpyObserver<[Cat]>(sut: sut).retrieved, [cats])
    }
    
    func test_loadCompletionWithCats_doesNotNotifyError() {
        let (sut, loader) = makeSut()
        
        sut.subscribeCats()
        loader.complete(with: [])
        
        XCTAssertEqual(SpyObserver<NSError>(sut: sut).retrieved, [])
    }
    
    func test_loadCompletionWithError_notifiesError() {
        let (sut, loader) = makeSut()
        let error = anyError()
        let errorObserver = SpyObserver<NSError>(sut: sut)
        
        sut.subscribeCats()
        loader.complete(with: error, at: 0)
        
        XCTAssertEqual(errorObserver.retrieved, [error])
        XCTAssertEqual(SpyObserver<NSError>(sut: sut).retrieved, [])
        
        sut.subscribeCats()
        loader.complete(with: error, at: 1)
        
        XCTAssertEqual(errorObserver.retrieved, [error, error])
        XCTAssertEqual(SpyObserver<NSError>(sut: sut).retrieved, [])
    }
    
    func test_cancelSubscription_doesNotNotify() {
        let (sut, loader) = makeSut()
        
        var retrieved = [[Cat]]()
        sut.subscribe(onNext: { retrieved.append($0) }).cancel()
        _ = sut.subscribe(onNext: { retrieved.append($0) })
        
        XCTAssertEqual(retrieved, [])
        
        loader.complete(with: makeCats())
        XCTAssertEqual(retrieved, [])
    }
    
    func test_cancelErrorSubscription_doesNotNotify() {
        let (sut, loader) = makeSut()
        
        var retrieved = [NSError]()
        sut.subscribeCats()
        sut.subscribe(onError: { retrieved.append($0 as NSError) }).cancel()
        _ = sut.subscribe(onError: { retrieved.append($0 as NSError) })
        
        XCTAssertEqual(retrieved, [])
        
        loader.complete(with: anyError())
        XCTAssertEqual(retrieved, [])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: Service, loader: CatsLoaderSpy)
    {
        let loader = CatsLoaderSpy()
        let sut = Service(loader: loader)
        
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
    
    fileprivate final class CatsLoaderSpy: Loader {
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
}

private extension Service {
    func subscribeCats() {
        _ = subscribe(onNext: { _ in })
    }
}


private extension SpyObserver where Value == [Cat] {
    convenience init(sut: Service) {
        self.init(sut.subscribe(onNext:))
    }
}

private extension SpyObserver where Value == NSError {
    convenience init(sut: Service) {
        self.init { observeBlock in
            sut.subscribe(onError: {
                observeBlock($0 as NSError)
            })
        }
    }
}
