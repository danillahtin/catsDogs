//
//  UserDefaultsTokenStore.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation
import Core

final class UserDefaultsTokenStore {
    private struct CodableToken: Codable {
        let login: String
        let password: String
        let expirationDate: Date
        
        init(token: AccessToken) {
            self.login = token.credentials.login
            self.password = token.credentials.password
            self.expirationDate = token.expirationDate
        }
        
        func token() -> AccessToken {
            AccessToken(credentials: Credentials(login: login, password: password),
                        expirationDate: expirationDate)
        }
    }
    
    enum Error: Swift.Error {
        case dataNotFound
    }
    
    let userDefaults: UserDefaults
    private let key = "UserDefaultsTokenStore.tokenKey"
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsTokenStore: TokenSaver {
    func save(token: AccessToken, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
        do {
            let data = try JSONEncoder().encode(CodableToken(token: token))
            userDefaults.set(data, forKey: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}


extension UserDefaultsTokenStore: TokenLoader {
    func load(_ completion: @escaping (Result<AccessToken, Swift.Error>) -> ()) {
        guard let data = userDefaults.data(forKey: key) else {
            return completion(.failure(Error.dataNotFound))
        }
        
        do {
            let token = try JSONDecoder().decode(CodableToken.self, from: data)
            completion(.success(token.token()))
        } catch {
            completion(.failure(error))
        }
    }
}
