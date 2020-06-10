//
//  RemoteApiStub.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation
import Core


final class RemoteApiStub {
    enum Error: LocalizedError {
        case invalidLoginOrPassword
        case serverUnavailable
        case unauthorized
        case notFound
        
        var errorDescription: String? {
            switch self {
            case .invalidLoginOrPassword:
                return "Invalid login or password"
            case .serverUnavailable:
                return "Server is unavailable, try again later"
            case .unauthorized:
                return "Unauthorized"
            case .notFound:
                return "Not found"
            }
        }
    }
    
    private var token: AccessToken?
    
    private let ttl: TimeInterval = 60 * 5
    private let database = RemoteDatabase()
    
    private func dispatch(_ block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            block()
        })
    }
    
    func sign(with token: AccessToken) {
        self.token = token
    }
}


extension RemoteApiStub: RemoteApi {
    func authorize(
        with credentials: Credentials,
        _ completion: @escaping (Result<AccessToken, Swift.Error>) -> ())
    {
        dispatch { [database, ttl] in
            guard database.validCredentials.contains(credentials) else {
                completion(.failure(Error.invalidLoginOrPassword))
                return
            }
            
            let token = AccessToken(credentials: credentials,
                                    expirationDate: Date(timeIntervalSinceNow: ttl))
            completion(.success(token))
        }
    }
    
    func logout(_ completion: @escaping (Result<Void, Swift.Error>) -> ()) {
        dispatch { [weak self] in
            self?.token = nil
            completion(.success(()))
        }
    }
    
    func profile(_ completion: @escaping (Result<ProfileInfo, Swift.Error>) -> ()) {
        dispatch { [weak self] in
            guard let self = self else {
                return completion(.failure(Error.serverUnavailable))
            }
            
            guard let token = self.token else {
                return completion(.failure(Error.unauthorized))
            }
            
            guard token.expirationDate > Date() else {
                return completion(.failure(Error.unauthorized))
            }
            
            guard let info = self.database.profileInfo[token.credentials.login] else {
                return completion(.failure(Error.notFound))
            }
            
            completion(.success(info))
        }
    }
    
    func cats(_ completion: @escaping (Result<[Cat], Swift.Error>) -> ()) {
        dispatch { [weak self] in
            guard let self = self else {
                return completion(.failure(Error.serverUnavailable))
            }
            
            completion(.success(self.database.cats))
        }
    }
    
    func dogs(_ completion: @escaping (Result<[Dog], Swift.Error>) -> ()) {
        dispatch { [weak self] in
            guard let self = self else {
                return completion(.failure(Error.serverUnavailable))
            }
            
            guard let token = self.token else {
                return completion(.failure(Error.unauthorized))
            }
            
            guard token.expirationDate > Date() else {
                return completion(.failure(Error.unauthorized))
            }
            
            completion(.success(self.database.dogs))
        }
    }
}

