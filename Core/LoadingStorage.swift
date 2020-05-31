//
//  LoadingStorage.swift
//  Core
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation


public final class LoadingStorage<LoaderType: Loader> {
    public typealias Entity = LoaderType.Entity
    private typealias Observer<T> = (T) -> ()
    
    private let loader: LoaderType
    private var catObservers: [UUID: Observer<[Entity]>] = [:]
    private var errorObservers: [UUID: Observer<Error>] = [:]
    
    private var cats: [Entity]?
    
    public init(loader: LoaderType) {
        self.loader = loader
    }
    
    public func subscribe(onNext: @escaping ([Entity]) -> ()) -> Cancellable {
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
    
    public func subscribe(onError: @escaping (Error) -> ()) -> Cancellable {
        let token = UUID()
        let cancellable = CancellableBlock { [weak self] in
            self?.errorObservers[token] = nil
        }
        
        errorObservers[token] = onError
        
        return cancellable
    }
    
    private func handle(loadResult: Result<[Entity], Error>) {
        switch loadResult {
        case .success(let cats):
            self.cats = cats
            notify(with: cats)
        case .failure(let error):
            notify(with: error)
        }
    }
    
    private func notify(with error: Error) {
        errorObservers.forEach({ $0.value(error) })
    }
    
    private func notify(with cats: [Entity]) {
        catObservers.forEach({ $0.value(cats) })
    }
}
