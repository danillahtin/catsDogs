//
//  DogListViewControllerAdapter.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import Core
import UI

final class DogListViewControllerAdapter {
    let controller: EntityListViewController<Dog>
    let errorView: ErrorView
    let notPurchasedLabel = UILabel()
    
    init(
        controller: EntityListViewController<Dog>,
        errorView: ErrorView)
    {
        self.controller = controller
        self.errorView = errorView
    }
    
    func display(error: Error) {
        guard case .unauthorized = error as? RemoteApiStub.Error else {
            return errorView.display(error: error)
        }
        
        notPurchasedLabel.isHidden = false
        notPurchasedLabel.text = "Content is not available\nfor unauthorized users"
        notPurchasedLabel.textAlignment = .center
        
        controller.loadViewIfNeeded()
        controller.tableView.backgroundView = notPurchasedLabel
        controller.entitiesUpdated(with: [])
    }
    
    func entitiesUpdated(with dogs: [Dog]) {
        notPurchasedLabel.isHidden = true
        controller.entitiesUpdated(with: dogs)
    }
}
