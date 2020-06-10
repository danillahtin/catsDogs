//
//  ActivityIndicatorView.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


final class ActivityIndicatorView {
    private let lock = NSRecursiveLock()
    private lazy var view: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .gray
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        UIApplication.shared.windows.first?.addSubview(view)
        view.frame = UIScreen.main.bounds
        view.isHidden = true
        view.hidesWhenStopped = true
        view.stopAnimating()
        
        return view
    }()
    
    private var requestsCount: Int = 0 {
        didSet {
            if requestsCount > 0 {
                view.startAnimating()
            } else {
                view.stopAnimating()
            }
        }
    }
}


extension ActivityIndicatorView: ActivityIndicator {
    func startLoading() {
        lock.lock(); defer { lock.unlock() }
        requestsCount += 1
    }
    
    func stopLoading() {
        lock.lock(); defer { lock.unlock() }
        
        requestsCount -= 1
        
        assert(requestsCount >= 0, "Unbalanced call to stopLoading")
    }
}
