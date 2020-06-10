//
//  CompositionRoot.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import Core
import UI

class CompositionRoot {
    let api = RemoteApiStub()
    lazy var catsStorage = LoadingStorage(loader: LoaderAdapter(load: api.cats))
    lazy var dogsStorage = LoadingStorage(loader: LoaderAdapter(load: api.dogs))
    
    private var subscriptions: [Cancellable] = []
    
    func compose() -> (nc: UINavigationController, flow: Flow) {
        let initialViewController = UIViewController()
        initialViewController.view.backgroundColor = .white
        
        let navigationController = UINavigationController(rootViewController: initialViewController)
        let errorView = ErrorView(presentingViewController: navigationController)
        let userDefaults = UserDefaults.standard
        let tokenStore = UserDefaultsTokenStore(userDefaults: userDefaults)
        let sessionController = SessionController(authorizeApi: api, tokenSaver: tokenStore, profileLoader: api, tokenLoader: tokenStore)
        let imageLoader = ImageLoaderStub()
        
        let catsViewController = EntityListViewController<Cat>(imageLoader: imageLoader)
        let dogsViewController = EntityListViewController<Dog>(imageLoader: imageLoader)
        
        subscriptions = [
            catsStorage.subscribe(onError: errorView.display),
            dogsStorage.subscribe(onError: errorView.display),
        ]
        
        let profileViewController = ProfileViewController()
        profileViewController.profileUpdated(state: .unauthorized)
        
        let mainFlow = MainFlow(
            catsViewControllerBuilder: { [unowned self, catsStorage] in
                let subscription = catsStorage.subscribe(onNext: catsViewController.entitiesUpdated)
                self.subscriptions.append(subscription)
                
                return catsViewController
            }, dogsViewControllerBuilder: { [unowned self, dogsStorage] in
                let subscription = dogsStorage.subscribe(onNext: dogsViewController.entitiesUpdated)
                self.subscriptions.append(subscription)
                
                return dogsViewController
            },
            profileViewControllerBuilder: {
                profileViewController
            },
            navigationController: navigationController)

        let authFlow = PushAuthFlow(
            loginRequest: sessionController,
            navigationController: navigationController,
            onComplete: mainFlow.start,
            onError: errorView.display)
        
        let flow = AppStartFlow(
            userDefaults: userDefaults,
            sessionChecking: sessionController,
            main: mainFlow,
            auth: authFlow)
        
        return (navigationController, flow)
    }
}

final class LoaderAdapter<Entity>: Loader {
    typealias Completion = (Result<[Entity], Error>) -> ()
    
    private let loadBlock: (@escaping Completion) -> ()
    
    init(load: @escaping (@escaping Completion) -> ()) {
        self.loadBlock = load
    }
    
    func load(_ completion: @escaping (Result<[Entity], Error>) -> ()) {
        loadBlock(completion)
    }
}

import SDWebImage

final class ImageLoaderStub: ImageLoader {
    func load(from url: URL, into imageView: UIImageView?) {
        imageView?.sd_setImage(with: url, completed: nil)
    }
}


extension UINavigationController: UINavigationControllerProtocol {}
