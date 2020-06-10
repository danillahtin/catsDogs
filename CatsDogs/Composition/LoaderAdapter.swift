//
//  LoaderAdapter.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core


final class LoaderAdapter<Entity>: Loader {
    typealias Completion = (Result<[Entity], Error>) -> ()
    
    private let loadBlock: (@escaping Completion) -> ()
    
    init(load: @escaping (@escaping Completion) -> ()) {
        self.loadBlock = load
    }
    
    func load(_ completion: @escaping (Result<[Entity], Error>) -> ()) {
        loadBlock(completion)
    }
}
