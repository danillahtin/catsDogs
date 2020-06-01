//
//  EntityListViewControllerTests.swift
//  UITests
//
//  Created by Danil Lahtin on 31.05.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import XCTest
import Core
import UI


class EntityListViewControllerTests: XCTestCase {
    func test_catsUpdated_doesNotLoadView() {
        let sut = makeSut()
        
        sut.catsUpdated(with: [])
        
        XCTAssertFalse(sut.isViewLoaded)
    }
    
    func test_loadView_rendersEmptyList() {
        let sut = makeSut()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.renderedViewsCount, 0)
    }
    
    func test_loadView_rendersUpdatedCats() {
        let sut = makeSut()
        
        let cats = [
            makeCat(name: "Buffy"),
            makeCat(name: "Buckwheat"),
        ]
        
        sut.catsUpdated(with: cats)
        sut.loadViewIfNeeded()
        
        assert(sut: sut, renders: cats)
        
        sut.catsUpdated(with: cats.reversed())
        assert(sut: sut, renders: cats.reversed())
        
        sut.catsUpdated(with: [])
        assert(sut: sut, renders: [])
    }
    
    func test_renderCats_loadsImages() {
        let imageLoader = ImageLoaderSpy()
        let sut = makeSut(imageLoader: imageLoader)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(imageLoader.requestedUrls, [])
        
        let buffy = makeCat(name: "Buffy", url: "buffy.url")
        let buckwheat = makeCat(name: "Buckwheat", url: "buckwheat.url")
        
        sut.catsUpdated(with: [buffy])
        _ = sut.view(at: 0)
        XCTAssertEqual(imageLoader.requestedUrls, ["buffy.url"])
        
        sut.catsUpdated(with: [buckwheat, buffy])
        _ = sut.view(at: 0)
        XCTAssertEqual(imageLoader.requestedUrls,
                       ["buffy.url", "buckwheat.url"])
        
        _ = sut.view(at: 1)
        XCTAssertEqual(imageLoader.requestedUrls,
                       ["buffy.url", "buckwheat.url", "buffy.url"])
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        imageLoader: ImageLoaderSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line) -> EntityListViewController<Cat>
    {
        let sut = EntityListViewController<Cat>(
            imageLoader: imageLoader)
        
        trackMemoryLeaks(for: sut, file: file, line: line)
        trackMemoryLeaks(for: imageLoader, file: file, line: line)
        
        return sut
    }
    
    private func makeCat(
        name: String = "noname",
        url: String = "any.url") -> Cat
    {
        Cat(id: UUID(), name: name, imageUrl: URL(string: url)!)
    }
    
    private func assert(
        sut: EntityListViewController<Cat>,
        renders cats: [Cat],
        file: StaticString = #file,
        line: UInt = #line)
    {
        XCTAssertEqual(
            sut.renderedViewsCount,
            cats.count,
            "Expected to render \(cats.count) views, got \(sut.renderedViewsCount) instead",
            file: file,
            line: line)
        
        for (index, cat) in cats.enumerated() {
            let renderedName = sut.view(at: index)?.title
            
            XCTAssertEqual(
                renderedName,
                cat.name,
                "Expected to render name \(cat.name) at index \(index), got \(String(describing: renderedName)) instead",
                file: file,
                line: line)
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


private extension EntityListViewController {
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
