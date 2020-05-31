//
//  CatListViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest


final class CatListViewController: UIViewController {
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
}

extension CatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

class CatListViewControllerTests: XCTestCase {
    func test_loadView_rendersEmptyList() {
        XCTAssertEqual(makeSut().renderedViewsCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> CatListViewController
    {
        let sut = CatListViewController()
        sut.loadViewIfNeeded()
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        
        return sut
    }
}


private extension CatListViewController {
    var renderedViewsCount: Int {
        tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0)
    }
}
