//
//  SessionController.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core

protocol AuthorizeApi {
    func authorize(with credentials: Credentials)
}


final class SessionController {
    private let authorizeApi: AuthorizeApi
    private let profileLoader: ProfileLoader
    private let tokenLoader: TokenLoader
    
    init(authorizeApi: AuthorizeApi,
         profileLoader: ProfileLoader,
         tokenLoader: TokenLoader) {
        self.authorizeApi = authorizeApi
        self.profileLoader = profileLoader
        self.tokenLoader = tokenLoader
    }
    
    func start(credentials: Credentials) {
        authorizeApi.authorize(with: credentials)
    }
}
    
extension SessionController: SessionChecking {
    func check(_ completion: @escaping (SessionCheckResult) -> ()) {
        tokenLoader.load { [profileLoader] in
            switch $0 {
            case .success:
                profileLoader.load {
                    switch $0 {
                    case .success:
                        completion(.exists)
                    case .failure:
                        completion(.invalid)
                    }
                }
            case .failure:
                completion(.notFound)
            }
        }
    }
}
