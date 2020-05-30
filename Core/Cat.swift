//
//  Cat.swift
//  Core
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation


public struct Cat: Equatable {
    public let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}
