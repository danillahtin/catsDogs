//
//  Loader.swift
//  Core
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

public protocol Loader {
    associatedtype Entity
    
    func load(_ completion: @escaping (Result<[Entity], Error>) -> ())
}
