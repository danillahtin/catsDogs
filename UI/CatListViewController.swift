//
//  CatListViewController.swift
//  UI
//
//  Created by Danil Lahtin on 01.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import Core


public final class CatListViewController: UIViewController {
    public private(set) weak var tableView: UITableView!
    
    private var imageLoader: ImageLoader!
    
    private var cats: [Cat] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    public convenience init(imageLoader: ImageLoader) {
        self.init()
        
        self.imageLoader = imageLoader
    }
    
    public override func loadView() {
        let tableView = UITableView()
        
        self.view = tableView
        self.tableView = tableView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
}

extension CatListViewController {
    public func catsUpdated(with cats: [Cat]) {
        self.cats = cats
    }
}

extension CatListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cats.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = cats[indexPath.row].name
        imageLoader.load(from: cats[indexPath.row].imageUrl, into: cell.imageView)
        
        return cell
    }
}
