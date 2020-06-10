//
//  PushAuthFlow.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core
import UI

final class PushAuthFlow: Flow {
    private let loginRequest: LoginRequest
    private let navigationController: UINavigationControllerProtocol
    private let onComplete: () -> ()
    
    init(loginRequest: LoginRequest,
         navigationController: UINavigationControllerProtocol,
         onComplete: @escaping () -> ())
    {
        self.loginRequest = loginRequest
        self.navigationController = navigationController
        self.onComplete = onComplete
    }
    
    func start() {
        let vc = LoginViewController()
        vc.didSkip = onComplete
        vc.didLogin = { [loginRequest, onComplete] in
            loginRequest.start(credentials: $0, {
                switch $0 {
                case .success:
                    onComplete()
                case .failure:
                    break
                }
            })
        }
        
        navigationController.setViewControllers([vc], animated: true)
    }
}
