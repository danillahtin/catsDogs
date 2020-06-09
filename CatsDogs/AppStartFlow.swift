//
//  AppStartFlow.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation


final class AppStartFlow {
    private let userDefaults: UserDefaults
    private let sessionChecking: SessionChecking
    private let main: Flow
    private let auth: Flow
    
    init(userDefaults: UserDefaults, sessionChecking: SessionChecking, main: Flow, auth: Flow) {
        self.userDefaults = userDefaults
        self.sessionChecking = sessionChecking
        self.main = main
        self.auth = auth
    }
    
    func start() {
        let notFoundFlow = ConditionalFlowComposite(primary: main, secondary: auth, condition: { [userDefaults] in
            userDefaults.bool(forKey: "hasSkippedAuth")
        })
        
        sessionChecking.check { [main, auth] in
            switch $0 {
            case .exists:
                main.start()
            case .invalid:
                auth.start()
            case .notFound:
                notFoundFlow.start()
            }
        }
    }
}
