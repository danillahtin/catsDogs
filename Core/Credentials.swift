//
//  Credentials.swift
//  Core
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

public struct Credentials: Equatable {
    public let login: String
    public let password: String
    
    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}
