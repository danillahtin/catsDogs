//
//  Dog.swift
//  Core
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation


public struct Dog: Equatable {
    public let id: UUID
    public let name: String
    public let imageUrl: URL
    
    public init(
        id: UUID,
        name: String,
        imageUrl: URL)
    {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
}
