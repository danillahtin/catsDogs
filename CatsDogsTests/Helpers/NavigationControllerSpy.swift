//
//  NavigationControllerSpy.swift
//  CatsDogsTests
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
@testable import CatsDogs

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
