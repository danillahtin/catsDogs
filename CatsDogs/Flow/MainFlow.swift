//
//  MainFlow.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


final class MainFlow: Flow {
    typealias ViewControllerBuilder = () -> UIViewController
    
    private let navigationController: UINavigationControllerProtocol
    private let catsViewControllerBuilder: ViewControllerBuilder
    private let dogsViewControllerBuilder: ViewControllerBuilder
    private let profileViewControllerBuilder: ViewControllerBuilder
    
    init(
        catsViewControllerBuilder: @escaping ViewControllerBuilder,
        dogsViewControllerBuilder: @escaping ViewControllerBuilder,
        profileViewControllerBuilder: @escaping ViewControllerBuilder,
        navigationController: UINavigationControllerProtocol)
    {
        self.navigationController = navigationController
        self.catsViewControllerBuilder = catsViewControllerBuilder
        self.dogsViewControllerBuilder = dogsViewControllerBuilder
        self.profileViewControllerBuilder = profileViewControllerBuilder
    }
    
    func start() {
        let catsVc = catsViewControllerBuilder()
        let dogsVc = dogsViewControllerBuilder()
        let profileVc = profileViewControllerBuilder()
        
        catsVc.tabBarItem = UITabBarItem(title: "Cats", image: .tabbar(named: "tabbar_cat"), selectedImage: nil)
        dogsVc.tabBarItem = UITabBarItem(title: "Dogs", image: .tabbar(named: "tabbar_dog"), selectedImage: nil)
        profileVc.tabBarItem = UITabBarItem(title: "Profile", image: .tabbar(named: "tabbar_profile"), selectedImage: nil)
        
        let vc = UITabBarController()
        vc.viewControllers = [catsVc, dogsVc, profileVc]
        
        navigationController.setViewControllers([vc], animated: true)
    }
}


private extension UIImage {
    static func tabbar(named: String) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        UIImage(named: named)!.draw(in: rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return result
    }
}
