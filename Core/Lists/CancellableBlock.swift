//
//  CancellableBlock.swift
//  Core
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//


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
