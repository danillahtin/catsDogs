//
//  LoginRequest.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

public protocol LoginRequest {
    func start(credentials: Credentials,
               _ completion: @escaping (Result<Void, Error>) -> ())
}

