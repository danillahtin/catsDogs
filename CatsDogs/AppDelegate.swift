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
    var window: UIWindow?
    var flow: Flow!
    var navigationController: UINavigationController!
    
    let compositionRoot = CompositionRoot()
    
    override init() {
        (navigationController, flow) = compositionRoot.compose()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        flow.start()
        
        return true
    }
}
