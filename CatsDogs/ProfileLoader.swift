//
//  ProfileLoader.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

protocol ProfileLoader {
    func load(_ completion: @escaping (Result<ProfileInfo, Error>) -> ())
}
