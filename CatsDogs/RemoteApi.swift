//
//  RemoteApi.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation
import Core


protocol RemoteApi {
    func authorize(
        with credentials: Credentials,
        _ completion: @escaping (Result<AccessToken, Swift.Error>) -> ())
    
    func logout(_ completion: @escaping (Result<Void, Swift.Error>) -> ())
    func profile(_ completion: @escaping (Result<ProfileInfo, Swift.Error>) -> ())
    func cats(_ completion: @escaping (Result<[Cat], Error>) -> ())
    func dogs(_ completion: @escaping (Result<[Dog], Error>) -> ())
}
