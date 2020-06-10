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

extension EntityListViewController where Entity == Dog {
    public convenience init(imageLoader: ImageLoader) {
        self.init(cellFactory: dogCellFactory(imageLoader: imageLoader))
    }
}

private func dogCellFactory(imageLoader: ImageLoader)
    -> (UITableView, IndexPath, Dog) -> UITableViewCell
{
    return { _, _, dog in
        let cell = UITableViewCell()
        
        cell.textLabel?.text = dog.name
        imageLoader.load(from: dog.imageUrl, into: cell.imageView)
        
        return cell
    }
}
