//
//  CatListViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core


protocol Publisher {
    func subscribe(_ observer: @escaping ([Cat]) -> ())
}

final class CatListViewController: UIViewController {
    let tableView = UITableView()
    
    private var publisher: Publisher!
    
    private var cats: [Cat] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(publisher: Publisher) {
        self.init()
        
        self.publisher = publisher
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        publisher.subscribe { [weak self] in self?.cats = $0 }
    }
}

extension CatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.textLabel?.text = cats[indexPath.row].name
        
        return cell
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
    
    func test_publisherNotification_rendersCats() {
        let publisher = PublisherStub()
        let sut = makeSut(publisher: publisher)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.renderedViewsCount, 0)
        
        let buffy = makeCat(name: "Buffy")
        let buckwheat = makeCat(name: "Buckwheat")
        
        publisher.notify(with: [buffy])
        XCTAssertEqual(sut.renderedViewsCount, 1)
        XCTAssertEqual(sut.view(at: 0)?.title, "Buffy")

        publisher.notify(with: [buckwheat, buffy])
        XCTAssertEqual(sut.renderedViewsCount, 2)
        XCTAssertEqual(sut.view(at: 0)?.title, "Buckwheat")
        XCTAssertEqual(sut.view(at: 1)?.title, "Buffy")
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
    
    private func makeCat(name: String = "noname") -> Cat {
        Cat(id: UUID(), name: name, imageUrls: [])
    }
    
    private final class PublisherStub: Publisher {
        var subscribers: [([Cat]) -> ()] = []
        
        func subscribe(_ observer: @escaping ([Cat]) -> ()) {
            subscribers.append(observer)
        }
        
        func notify(with cats: [Cat]) {
            subscribers.forEach({ $0(cats) })
        }
    }
}


private extension CatListViewController {
    var renderedViewsCount: Int {
        tableView.numberOfRows(inSection: 0)
    }
    
    func view(at index: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: index, section: 0)
        
        return tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
}


private extension UITableViewCell {
    var title: String? {
        textLabel?.text
    }
}
