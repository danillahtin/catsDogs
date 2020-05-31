//
//  CatService.swift
//  Core
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation

public protocol Cancellable {
    func cancel()
}

final class CancellableBlock: Cancellable {
    let cancelBlock: () -> ()
    
    init(cancelBlock: @escaping () -> ()) {
        self.cancelBlock = cancelBlock
    }
    
    deinit {
        cancelBlock()
    }
    
    func cancel() {
        cancelBlock()
    }
}

public final class CatService {
    private typealias Observer<T> = (T) -> ()
    
    private let loader: CatLoader
    private var catObservers: [UUID: Observer<[Cat]>] = [:]
    private var errorObservers: [Observer<Error>] = []
    
    private var cats: [Cat]?
    
    public init(loader: CatLoader) {
        self.loader = loader
    }
    
    public func subscribe(onNext: @escaping ([Cat]) -> ()) -> Cancellable {
        let token = UUID()
        let cancellable = CancellableBlock { [weak self] in
            self?.catObservers[token] = nil
        }
        
        catObservers[token] = onNext
        
        if let cats = cats {
            onNext(cats)
            return cancellable
        }
        
        loader.load { [weak self] in
            self?.handle(loadResult: $0)
        }
        
        return cancellable
    }
    
    public func subscribe(onError: @escaping (Error) -> ()) {
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
        catObservers.forEach({ $0.value(cats) })
    }
}
