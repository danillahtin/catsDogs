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
    private let validCredentials: [Credentials] = [
        Credentials(login: "admin", password: "admin"),
    ]
    private let profileInfo: [String: ProfileInfo] = [
        "admin": ProfileInfo(username: "John Appleseed"),
    ]
    
    private let cats: [Cat] = [
        Cat(id: UUID(), name: "Fluffy", imageUrl: URL(string: "https://cs6.pikabu.ru/avatars/1779/v1779855-644770512.jpg")!),
        Cat(id: UUID(), name: "Buckwheat", imageUrl: URL(string: "https://i.pinimg.com/736x/0e/cc/7b/0ecc7b3561ee63d699c9cfc760dc15fd.jpg")!),
        Cat(id: UUID(), name: "Barbie", imageUrl: URL(string: "https://dv-gazeta.info/wp-content/uploads/2019/09/seryy-polosatyy-kot-s-zolotymi-glazami-smotrit-v-obektiv-700x329-470x246.jpg")!),
        Cat(id: UUID(), name: "Homer", imageUrl: URL(string: "https://hdwallsbox.com/wallpapers/m/4/cats-animals-yellow-eyes-m3124.jpg")!),
        Cat(id: UUID(), name: "Dewey", imageUrl: URL(string: "https://zastavok.net/ts/animals/1470780371.jpg")!),
        Cat(id: UUID(), name: "Flash", imageUrl: URL(string: "https://i.pinimg.com/236x/7a/2c/ca/7a2cca034f2a4b1fbf7c99b17ac1a687.jpg")!),
    ]
    
    private func dispatch(_ block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            block()
        })
    }
}


extension Api {
    func sign(with token: AccessToken) {
        self.token = token
    }
    
    func authorize(
        with credentials: Credentials,
        _ completion: @escaping (Result<AccessToken, Swift.Error>) -> ())
    {
        dispatch { [validCredentials, ttl] in
            guard validCredentials.contains(credentials) else {
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
            
            guard let info = self.profileInfo[token.credentials.login] else {
                return completion(.failure(Error.notFound))
            }
            
            completion(.success(info))
        }
    }
    
    func cats(_ completion: @escaping (Result<[Cat], Error>) -> ()) {
        dispatch { [weak self] in
            guard let self = self else {
                return completion(.failure(Error.serverUnavailable))
            }
            
            completion(.success(self.cats))
        }
    }
}

