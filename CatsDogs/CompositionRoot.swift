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
    private var subscriptions: [Cancellable] = []
    
    func compose() -> (nc: UINavigationController, flow: Flow) {
        let navigationController = UINavigationController(rootViewController: buildInitialViewController())
        let errorView = ErrorView(presentingViewController: navigationController)
        let userDefaults = UserDefaults.standard
        let api = RemoteApiStub()
        let tokenStore = UserDefaultsTokenStore(userDefaults: userDefaults)
        let sessionController = SessionController(authorizeApi: api, tokenSaver: tokenStore, profileLoader: api, tokenLoader: tokenStore)
        let imageLoader = ImageLoaderStub()
        
        let catsStorage = LoadingStorage(loader: LoaderAdapter(load: api.cats))
        let dogsStorage = LoadingStorage(loader: LoaderAdapter(load: api.dogs))
        
        let catsViewController = EntityListViewController<Cat>(imageLoader: imageLoader)
        let dogsViewController = EntityListViewController<Dog>(imageLoader: imageLoader)
        
        catsViewController.didRefresh = catsStorage.refresh
        dogsViewController.didRefresh = dogsStorage.refresh
        
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
    
    private func buildInitialViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .gray
        activityIndicatorView.startAnimating()
        
        vc.view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        return vc
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
