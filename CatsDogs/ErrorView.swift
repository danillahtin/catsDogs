//
//  ErrorView.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


final class ErrorView {
    weak var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func display(error: Error) {
        let alertVc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        alertVc.addAction(.init(title: "Ok", style: .default, handler: nil))
        
        presentingViewController?.present(alertVc, animated: true, completion: nil)
    }
}
