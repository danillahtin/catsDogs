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
        let rootNc = UINavigationController(rootViewController: buildInitialViewController())
        let errorView = ErrorView(presentingViewController: rootNc)
        let userDefaults = UserDefaults.standard
        let api = RemoteApiStub()
        let tokenStore = UserDefaultsTokenStore(userDefaults: userDefaults)
        let sessionController = SessionController(
            authorizeApi: ActivityIndicatorDecorator(api),
            logoutApi: ActivityIndicatorDecorator(api),
            tokenSaver: ActivityIndicatorDecorator(TokenSaverSerialComposite(savers: [tokenStore, api])),
            profileLoader: ActivityIndicatorDecorator(api),
            tokenLoader: ActivityIndicatorDecorator(TokenLoaderDecorator(didLoadToken: api.sign, decoratee: tokenStore)))
        let imageLoader = SDWebImageLoader()
        
        let catsStorage = LoadingStorage(loader: LoaderAdapter(load: api.cats))
        let dogsStorage = LoadingStorage(loader: LoaderAdapter(load: api.dogs))
        
        let catsViewController = EntityListViewController<Cat>(imageLoader: imageLoader)
        let dogsViewAdapter = DogListViewControllerAdapter(
            controller: EntityListViewController<Dog>(imageLoader: imageLoader),
            errorView: errorView)
        
        catsViewController.didRefresh = catsStorage.refresh
        dogsViewAdapter.controller.didRefresh = dogsStorage.refresh
        
        subscriptions = [
            catsStorage.subscribe(onError: errorView.display),
            dogsStorage.subscribe(onError: dogsViewAdapter.display),
        ]
        
        let profileViewController = ProfileViewController()
        sessionController.didUpdateProfileState = {
            profileViewController.profileUpdated(state: $0)
            dogsStorage.refresh()
        }
        
        profileViewController.onSignIn = { [weak presentingVc = rootNc] in
            let nc = UINavigationController()
            
            PushAuthFlow(
                userDefaults: userDefaults,
                loginRequest: sessionController,
                navigationController: nc,
                onComplete: { [weak nc] in nc?.dismiss(animated: true, completion: nil) },
                onError: errorView.display).start()
            
            presentingVc?.present(nc, animated: true, completion: nil)
        }
        
        profileViewController.onLogout = {
            sessionController.logout(tokenStore.clear)
        }
        
        let mainFlow = MainFlow(
            catsViewControllerBuilder: { [unowned self, catsStorage] in
                let subscription = catsStorage.subscribe(onNext: catsViewController.entitiesUpdated)
                self.subscriptions.append(subscription)
                
                return catsViewController
            }, dogsViewControllerBuilder: { [unowned self, dogsStorage] in
                let subscription = dogsStorage.subscribe(onNext: dogsViewAdapter.entitiesUpdated)
                self.subscriptions.append(subscription)
                
                return dogsViewAdapter.controller
            },
            profileViewControllerBuilder: {
                profileViewController
            },
            navigationController: rootNc)

        let authFlow = PushAuthFlow(
            userDefaults: userDefaults,
            loginRequest: sessionController,
            navigationController: rootNc,
            onComplete: mainFlow.start,
            onError: errorView.display)
        
        let flow = AppStartFlow(
            userDefaults: userDefaults,
            sessionChecking: sessionController,
            main: mainFlow,
            auth: authFlow)
        
        return (rootNc, flow)
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


private final class TokenLoaderDecorator: TokenLoader {
    let didLoadToken: (AccessToken) -> ()
    let decoratee: TokenLoader
    
    init(
        didLoadToken: @escaping (AccessToken) -> (),
        decoratee: TokenLoader)
    {
        self.didLoadToken = didLoadToken
        self.decoratee = decoratee
    }
    
    func load(_ completion: @escaping (Result<AccessToken, Error>) -> ()) {
        decoratee.load { [weak self] in
            switch $0 {
            case .success(let token):
                self?.didLoadToken(token)
            default:
                break
            }
            
            completion($0)
        }
    }
}
