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
    private var entitiesObservers: [UUID: Observer<[Entity]>] = [:]
    private var errorObservers: [UUID: Observer<Error>] = [:]
    
    private var entities: [Entity]?
    
    public init(loader: LoaderType) {
        self.loader = loader
    }
    
    public func subscribe(onNext: @escaping ([Entity]) -> ()) -> Cancellable {
        let token = UUID()
        let cancellable = CancellableBlock { [weak self] in
            self?.entitiesObservers[token] = nil
        }
        
        entitiesObservers[token] = onNext
        
        if let entities = entities {
            onNext(entities)
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
    
    public func refresh() {
        loader.load { [weak self] in
            self?.handle(loadResult: $0)
        }
    }
    
    private func handle(loadResult: Result<[Entity], Error>) {
        switch loadResult {
        case .success(let entities):
            self.entities = entities
            notify(with: entities)
        case .failure(let error):
            notify(with: error)
        }
    }
    
    private func notify(with error: Error) {
        errorObservers.forEach({ $0.value(error) })
    }
    
    private func notify(with entities: [Entity]) {
        entitiesObservers.forEach({ $0.value(entities) })
    }
}
