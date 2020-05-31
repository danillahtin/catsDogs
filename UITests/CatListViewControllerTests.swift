//
//  CatListViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core

protocol ImageLoader {
    func load(from url: URL, into imageView: UIImageView?)
}

protocol Publisher {
    func subscribe(_ observer: @escaping ([Cat]) -> ())
}

final class CatListViewController: UIViewController {
    let tableView = UITableView()
    
    private var publisher: Publisher!
    private var imageLoader: ImageLoader!
    
    private var cats: [Cat] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(
        publisher: Publisher,
        imageLoader: ImageLoader)
    {
        self.init()
        
        self.publisher = publisher
        self.imageLoader = imageLoader
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
        imageLoader.load(from: cats[indexPath.row].imageUrl, into: cell.imageView)
        
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
        let imageLoader = ImageLoaderSpy()
        let publisher = PublisherStub()
        let sut = makeSut(publisher: publisher, imageLoader: imageLoader)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.renderedViewsCount, 0)
        XCTAssertEqual(imageLoader.requestedUrls, [])
        
        let buffy = makeCat(name: "Buffy", url: "buffy.url")
        let buckwheat = makeCat(name: "Buckwheat", url: "buckwheat.url")
        
        publisher.notify(with: [buffy])
        XCTAssertEqual(sut.renderedViewsCount, 1)
        XCTAssertEqual(sut.view(at: 0)?.title, "Buffy")
        XCTAssertEqual(imageLoader.requestedUrls, ["buffy.url"])

        publisher.notify(with: [buckwheat, buffy])
        XCTAssertEqual(sut.renderedViewsCount, 2)
        XCTAssertEqual(sut.view(at: 0)?.title, "Buckwheat")
        XCTAssertEqual(sut.view(at: 1)?.title, "Buffy")
        XCTAssertEqual(imageLoader.requestedUrls,
                       ["buffy.url", "buckwheat.url", "buffy.url"])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        publisher: PublisherStub = .init(),
        imageLoader: ImageLoaderSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> CatListViewController
    {
        let sut = CatListViewController(
            publisher: publisher,
            imageLoader: imageLoader)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
       trackMemoryLeaks(for: publisher, file: file, line: line)
        trackMemoryLeaks(for: imageLoader, file: file, line: line)
        
        return sut
    }
    
    private func makeCat(
        name: String = "noname",
        url: String) -> Cat
    {
        Cat(id: UUID(), name: name, imageUrl: URL(string: url)!)
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
    
    private final class ImageLoaderSpy: ImageLoader {
        private var urls: [URL] = []
        
        var requestedUrls: [String] { urls.map({ $0.absoluteString }) }
        
        func load(from url: URL, into imageView: UIImageView?) {
            urls.append(url)
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
