//
//  CatsListener.swift
//  Core
//
//  Created by Danil Lahtin on 01.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//


public protocol CatsListener {
    func catsUpdated(with cats: [Cat])
}
