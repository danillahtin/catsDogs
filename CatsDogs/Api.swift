//
//  Api.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation
import Core

final class Api {
    enum Error: LocalizedError {
        case invalidLoginOrPassword
        
        var errorDescription: String? {
            switch self {
            case .invalidLoginOrPassword:
                return "Invalid login or password"
            }
        }
    }
    
    private let validCredentials: [Credentials] = [
        Credentials(login: "admin", password: "admin"),
    ]
    
    private func dispatch(_ block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            block()
        })
    }
}

extension Api {
    func authorize(
        with credentials: Credentials,
        _ completion: @escaping (Result<AccessToken, Swift.Error>) -> ())
    {
        dispatch { [validCredentials] in
            guard validCredentials.contains(credentials) else {
                completion(.failure(Error.invalidLoginOrPassword))
                return
            }
            
            completion(.success(AccessToken()))
        }
    }
}


extension Api: ProfileLoader {
    func load(_ completion: @escaping (Result<ProfileInfo, Swift.Error>) -> ()) {
        dispatch {
            completion(.success(ProfileInfo()))
        }
    }
}

