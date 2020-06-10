//
//  TokenSaverSerialComposite.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation


final class TokenSaverSerialComposite: TokenSaver {
    let savers: [TokenSaver]
    
    init(savers: [TokenSaver]) {
        self.savers = savers
    }
    
    func save(token: AccessToken, completion: @escaping (Result<Void, Error>) -> ()) {
        save(token: token, savers: savers, completion: completion)
    }
    
    private func save(token: AccessToken, savers: [TokenSaver], completion: @escaping (Result<Void, Error>) -> ()) {
        guard !savers.isEmpty else {
            return completion(.success(()))
        }
        
        var pending = savers
        let next = pending.removeFirst()
        
        next.save(token: token) { [self] in
            switch $0 {
            case .failure:
                completion($0)
            case .success:
                self.save(token: token, savers: pending, completion: completion)
            }
        }
    }
}
