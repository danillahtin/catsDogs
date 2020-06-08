//
//  MainFlowTests.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 08.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
@testable import CatsDogs


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


class MainFlowTests: XCTestCase {
    func test_init_doesNotSet() {
        let (_, navigationController) = makeSut()
        
        XCTAssertEqual(navigationController.messages, [])
    }
    
    func test_start_setsViewController() {
        let catsVc = UIViewController()
        let dogsVc = UIViewController()
        let profileVc = UIViewController()
        
        let (sut, navigationController) = makeSut(
            catsVcBuilder: { catsVc },
            dogsVcBuilder: { dogsVc },
            profileVcBuilder: { profileVc })
        
        sut.start()
        
        XCTAssertEqual(navigationController.messages.count, 1)
        XCTAssertEqual(navigationController.messages[0].viewControllers?.count, 1)
        XCTAssertEqual(navigationController.messages[0].animated, true)
        
        let rootVc = navigationController.messages[0].viewControllers?.first
        let tabBarController = rootVc as? UITabBarController
        
        XCTAssertNotNil(tabBarController)
        XCTAssertEqual(tabBarController?.viewControllers?.count, 3)
        
        XCTAssertEqual(tabBarController?.viewControllers?[0], catsVc)
        XCTAssertEqual(tabBarController?.viewControllers?[1], dogsVc)
        XCTAssertEqual(tabBarController?.viewControllers?[2], profileVc)
        
        XCTAssertEqual(catsVc.tabBarItem.title, "Cats")
        XCTAssertEqual(dogsVc.tabBarItem.title, "Dogs")
        XCTAssertEqual(profileVc.tabBarItem.title, "Profile")
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        catsVcBuilder: @escaping () -> UIViewController = UIViewController.init,
        dogsVcBuilder: @escaping () -> UIViewController = UIViewController.init,
        profileVcBuilder: @escaping () -> UIViewController = UIViewController.init,
        file: StaticString = #file,
        line: UInt = #line) -> (sut: MainFlow, navigationController: NavigationControllerSpy)
    {
        let navigationController = NavigationControllerSpy()
        let sut = MainFlow(
            catsViewControllerBuilder: catsVcBuilder,
            dogsViewControllerBuilder: dogsVcBuilder,
            profileViewControllerBuilder: profileVcBuilder,
            navigationController: navigationController)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: navigationController, file: file, line: line)
        
        return (sut, navigationController)
    }
    
    
}

final class NavigationControllerSpy: UINavigationControllerProtocol {
    enum Message: Equatable {
        case set(viewControllers: [UIViewController], animated: Bool)
        
        var viewControllers: [UIViewController]? {
            guard case .set(let viewControllers, _) = self else {
                return nil
            }
            
            return viewControllers
        }
        
        var animated: Bool? {
            guard case .set(_, let animated) = self else {
                return nil
            }
            
            return animated
        }
    }
    
    var messages: [Message] = []
    
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        messages.append(.set(viewControllers: viewControllers, animated: animated))
    }
}
