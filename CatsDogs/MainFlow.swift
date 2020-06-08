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
        
        catsVc.tabBarItem = UITabBarItem(title: "Cats", image: nil, selectedImage: nil)
        dogsVc.tabBarItem = UITabBarItem(title: "Dogs", image: nil, selectedImage: nil)
        profileVc.tabBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
        
        let vc = UITabBarController()
        vc.viewControllers = [catsVc, dogsVc, profileVc]
        
        navigationController.setViewControllers([vc], animated: true)
    }
}
