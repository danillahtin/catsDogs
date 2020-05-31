//
//  CatListViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest

protocol Publisher {
    func subscribe()
}

final class CatListViewController: UIViewController {
    let tableView = UITableView()
    
    private var publisher: Publisher!
    
    convenience init(publisher: Publisher) {
        self.init()
        
        self.publisher = publisher
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        publisher.subscribe()
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
        let sut = makeSut()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.renderedViewsCount, 0)
    }
    
    func test_loadView_subscribes() {
        let publisher = PublisherStub()
        let sut = makeSut(publisher: publisher)
        
        XCTAssertEqual(publisher.subscribers.count, 0)
        sut.loadViewIfNeeded()
        XCTAssertEqual(publisher.subscribers.count, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        publisher: PublisherStub = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> CatListViewController
    {
        let sut = CatListViewController(publisher: publisher)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: publisher, file: file, line: line)
        
        return sut
    }
    
    private final class PublisherStub: Publisher {
        var subscribers: [Void] = []
        
        func subscribe() {
            subscribers.append(())
        }
    }
}


private extension CatListViewController {
    var renderedViewsCount: Int {
        tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0)
    }
}
