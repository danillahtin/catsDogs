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
    public let name: String
    public let imageUrls: [URL]
    
    public init(
        id: UUID,
        name: String,
        imageUrls: [URL])
    {
        self.id = id
        self.name = name
        self.imageUrls = imageUrls
    }
}
