//
//  SessionChecking.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

protocol SessionChecking {
    func check(_ completion: @escaping (SessionCheckResult) -> ())
}
