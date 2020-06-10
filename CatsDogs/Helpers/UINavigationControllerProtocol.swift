//
//  UINavigationControllerProtocol.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 09.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


protocol UINavigationControllerProtocol {
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
}

extension UINavigationController: UINavigationControllerProtocol {}
