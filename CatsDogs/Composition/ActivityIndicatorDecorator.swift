//
//  ActivityIndicatorDecorator.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Core


protocol ActivityIndicator {
    func startLoading()
    func stopLoading()
}

final class ActivityIndicatorDecorator<Decoratee> {
    let decoratee: Decoratee
    let activityIndicator: ActivityIndicator
    
    init(_ decoratee: Decoratee, activityIndicator: ActivityIndicator = ActivityIndicatorView()) {
        self.decoratee = decoratee
        self.activityIndicator = activityIndicator
    }
}

extension ActivityIndicatorDecorator: AuthorizeApi where Decoratee: AuthorizeApi {
    func authorize(with credentials: Credentials, _ completion: @escaping (Result<AccessToken, Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.authorize(with: credentials) { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}

extension ActivityIndicatorDecorator: LogoutApi where Decoratee: LogoutApi {
    func logout(_ completion: @escaping (Result<Void, Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.logout { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}

extension ActivityIndicatorDecorator: ProfileApi where Decoratee: ProfileApi {
    func profile(_ completion: @escaping (Result<ProfileInfo, Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.profile { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}

extension ActivityIndicatorDecorator: ContentApi where Decoratee: ContentApi {
    func cats(_ completion: @escaping (Result<[Cat], Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.cats { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
    
    func dogs(_ completion: @escaping (Result<[Dog], Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.dogs { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}

extension ActivityIndicatorDecorator: TokenSaver where Decoratee: TokenSaver {
    func save(token: AccessToken, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.save(token: token) { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}

extension ActivityIndicatorDecorator: TokenLoader where Decoratee: TokenLoader {
    func load(_ completion: @escaping (Result<AccessToken, Swift.Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.load { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}


extension ActivityIndicatorDecorator: ProfileLoader where Decoratee: ProfileLoader {
    func load(_ completion: @escaping (Result<ProfileInfo, Swift.Error>) -> ()) {
        activityIndicator.startLoading()
        decoratee.load { [activityIndicator] in
            completion($0)
            activityIndicator.stopLoading()
        }
    }
}
