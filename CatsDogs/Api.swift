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
    
    private let dogs: [Dog] = [
        Dog(id: UUID(), name: "Rufus", imageUrl: URL(string: "https://info-4all.ru/images/1ea26de91427124bfe753493a0963382.jpg")!),
        Dog(id: UUID(), name: "Pumba", imageUrl: URL(string: "https://i.pinimg.com/236x/3a/5d/f8/3a5df859c29c0929252d6f3e007157b8.jpg")!),
        Dog(id: UUID(), name: "Butters", imageUrl: URL(string: "https://www.hvostik.by/upload/information_system_5/2/2/8/item_228/information_items_228.jpg")!),
        Dog(id: UUID(), name: "Snowball", imageUrl: URL(string: "https://avatars.mds.yandex.net/get-pdb/940654/1a2be3be-4024-4d86-8c3e-c3b560f94886/s375")!),
        Dog(id: UUID(), name: "Bob", imageUrl: URL(string: "https://img.uslugio.com/img/2f/a0/2fa03b0ae56b42d1615b37169abd7c4e.jpg")!),
        Dog(id: UUID(), name: "Peanut", imageUrl: URL(string: "https://avatars.mds.yandex.net/get-pdb/1927216/fc90329e-9835-4fba-af14-09269535ed57/s375")!),
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
    
    func dogs(_ completion: @escaping (Result<[Dog], Error>) -> ()) {
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
            
            completion(.success(self.dogs))
        }
    }
}

