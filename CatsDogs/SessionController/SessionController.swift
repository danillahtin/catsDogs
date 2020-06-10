//
//  SessionController.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core


final class SessionController {
    private let authorizeApi: AuthorizeApi
    private let tokenSaver: TokenSaver
    private let profileLoader: ProfileLoader
    private let tokenLoader: TokenLoader
    
    private(set) var profileInfo: ProfileInfo?
    
    init(authorizeApi: AuthorizeApi,
         tokenSaver: TokenSaver,
         profileLoader: ProfileLoader,
         tokenLoader: TokenLoader) {
        self.authorizeApi = authorizeApi
        self.tokenSaver = tokenSaver
        self.profileLoader = profileLoader
        self.tokenLoader = tokenLoader
    }
}

extension SessionController: LoginRequest {
    func start(credentials: Credentials, _ completion: @escaping (Result<Void, Error>) -> ()) {
        authorizeApi.authorize(with: credentials) { [tokenSaver, profileLoader] in
            switch $0 {
            case .failure:
                completion($0.map({ _ in () }))
            case .success(let token):
                tokenSaver.save(token: token) {
                    switch $0 {
                    case .failure(let error):
                        completion($0)
                    case .success:
                        profileLoader.load({ _ in})
                    }
                }
            }
        }
    }
}
    
extension SessionController: SessionChecking {
    func check(_ completion: @escaping (SessionCheckResult) -> ()) {
        tokenLoader.load { [weak self, profileLoader] in
            switch $0 {
            case .success:
                profileLoader.load {
                    switch $0 {
                    case .success(let info):
                        self?.profileInfo = info
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
