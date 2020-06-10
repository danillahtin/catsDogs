//
//  RemoteApiStub+TokeSaver.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

extension RemoteApiStub: TokenSaver {
    func save(token: AccessToken, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
        sign(with: token)
        completion(.success(()))
    }
}
