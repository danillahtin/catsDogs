//
//  EntityListViewController+Cat.swift
//  UI
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import Core


extension EntityListViewController where Entity == Cat {
    public convenience init(imageLoader: ImageLoader) {
        self.init(cellFactory: catCellFactory(imageLoader: imageLoader))
    }
    
    public func catsUpdated(with cats: [Cat]) {
        entitiesUpdated(with: cats)
    }
}


private func catCellFactory(imageLoader: ImageLoader)
    -> (UITableView, IndexPath, Cat) -> UITableViewCell
{
    return { _, _, cat in
        let cell = UITableViewCell()
        
        cell.textLabel?.text = cat.name
        imageLoader.load(from: cat.imageUrl, into: cell.imageView)
        
        return cell
    }
}
