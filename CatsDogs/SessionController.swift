//
//  SessionController.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core

protocol AuthorizeApi {
    func authorize(with credentials: Credentials, _ completion: @escaping (Result<AccessToken, Error>) -> ())
}


final class SessionController {
    private let authorizeApi: AuthorizeApi
    private let tokenSaver: TokenSaver
    private let profileLoader: ProfileLoader
    private let tokenLoader: TokenLoader
    
    init(authorizeApi: AuthorizeApi,
         tokenSaver: TokenSaver,
         profileLoader: ProfileLoader,
         tokenLoader: TokenLoader) {
        self.authorizeApi = authorizeApi
        self.tokenSaver = tokenSaver
        self.profileLoader = profileLoader
        self.tokenLoader = tokenLoader
    }
    
    func start(credentials: Credentials, _ completion: @escaping (Result<AccessToken, Error>) -> ()) {
        authorizeApi.authorize(with: credentials) { [tokenSaver] in
            switch $0 {
            case .failure:
                completion($0)
            case .success(let token):
                tokenSaver.save(token: token, completion: {
                    completion($0.map({ _ in token }))
                })
            }
        }
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
