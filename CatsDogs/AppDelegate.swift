//
//  AppDelegate.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 30.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var flow: Flow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        flow?.start()
        
//        let userDefaults = UserDefaults.standard
//        let api = RemoteApiStub()
//        let tokenStore = UserDefaultsTokenStore(userDefaults: userDefaults)
//        let sessionController = SessionController(profileLoader: api, tokenLoader: tokenStore)
//        let mainFlow = MainFlow(catsViewControllerBuilder: <#MainFlow.ViewControllerBuilder#>, dogsViewControllerBuilder: <#MainFlow.ViewControllerBuilder#>, profileViewControllerBuilder: <#MainFlow.ViewControllerBuilder#>, navigationController: <#UINavigationControllerProtocol#>
        
//        let authFlow = PushAuthFlow(loginRequest: <#T##LoginRequest#>, navigationController: <#T##UINavigationControllerProtocol#>, onComplete: <#T##() -> ()#>)
//        AppStartFlow(userDefaults: userDefaults, sessionChecking: sessionController, main: <#T##Flow#>, auth: <#T##Flow#>)
        
        return true
    }
}
