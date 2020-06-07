//
//  EntityListViewController.swift
//  UI
//
//  Created by Danil Lahtin on 01.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


public final class EntityListViewController<Entity>: UIViewController, UITableViewDataSource {
    public typealias CellFactory = (UITableView, IndexPath, Entity) -> UITableViewCell
    
    public private(set) weak var tableView: UITableView!
    private var cellFactory: CellFactory!
    
    private var entities: [Entity] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    public convenience init(cellFactory: @escaping CellFactory) {
        self.init()
        
        self.cellFactory = cellFactory
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
    
    public func entitiesUpdated(with entities: [Entity]) {
        self.entities = entities
    }
    
    // MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entities.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellFactory(tableView, indexPath, entities[indexPath.row])
    }
}
