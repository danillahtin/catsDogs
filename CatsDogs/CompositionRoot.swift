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
        let navigationController = UINavigationController()
        let userDefaults = UserDefaults.standard
        let api = RemoteApiStub()
        let tokenStore = UserDefaultsTokenStore(userDefaults: userDefaults)
        let sessionController = SessionController(authorizeApi: api, tokenSaver: tokenStore, profileLoader: api, tokenLoader: tokenStore)
        let imageLoader = ImageLoaderStub()
        
        let catsStorage = LoadingStorage(loader: LoaderAdapter(load: api.cats))
        let dogsStorage = LoadingStorage(loader: LoaderAdapter(load: api.dogs))

        let catsViewController = EntityListViewController<Cat>(imageLoader: imageLoader)
        let dogsViewController = EntityListViewController<Dog>(imageLoader: imageLoader)
        
        subscriptions = [
            catsStorage.subscribe(onNext: catsViewController.entitiesUpdated),
            dogsStorage.subscribe(onNext: dogsViewController.entitiesUpdated),
        ]
        
        let profileViewController = ProfileViewController()
        profileViewController.profileUpdated(state: .unauthorized)
        
        let mainFlow = MainFlow(
            catsViewControllerBuilder: { catsViewController },
            dogsViewControllerBuilder: { dogsViewController },
            profileViewControllerBuilder: { profileViewController },
            navigationController: navigationController)

        let authFlow = PushAuthFlow(
            loginRequest: sessionController,
            navigationController: navigationController,
            onComplete: mainFlow.start)
        
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


final class ImageLoaderStub: ImageLoader {
    func load(from url: URL, into imageView: UIImageView?) {
        // TODO
    }
}


extension UINavigationController: UINavigationControllerProtocol {}
