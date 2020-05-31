//
//  SpyObserver.swift
//  CoreTests
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core


final class SpyObserver<Value> {
    typealias ObserveBlock = (Value) -> ()
    typealias SubscribeBlock = (@escaping ObserveBlock) -> Cancellable
    
    private var subscription: Cancellable!
    private(set) var retrieved: [Value] = []
    
    init(_ block: SubscribeBlock) {
        subscription = block({ [weak self] in
            self?.retrieved.append($0)
        })
    }
}
