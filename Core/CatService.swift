//
//  CatService.swift
//  Core
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//


public final class CatService {
    private typealias Observer<T> = (T) -> ()
    
    private let loader: CatLoader
    private var catObservers: [Observer<[Cat]>] = []
    private var errorObservers: [Observer<Error>] = []
    
    private var cats: [Cat]?
    
    public init(loader: CatLoader) {
        self.loader = loader
    }
    
    public func subscribe(onNext: @escaping ([Cat]) -> ()) {
        catObservers.append(onNext)
        
        if let cats = cats {
            return onNext(cats)
        }
        
        loader.load { [weak self] in
            self?.handle(loadResult: $0)
        }
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
        catObservers.forEach({ $0(cats) })
    }
}
