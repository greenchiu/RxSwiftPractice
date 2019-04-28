//
//  RxSwiftPracticeTests.swift
//  RxSwiftPracticeTests
//
//  Created by GreenChiu on 2019/4/10.
//  Copyright © 2019 Green. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxNimble
import Nimble
import RxTest

@testable import RxSwiftPractice

class RxSwiftPracticeTests: XCTestCase {

    private var bag: DisposeBag!
    
    override func setUp() {
        bag = DisposeBag()
    }
    
    func test() {
        let viewModel = SimpleRxViewModel(apiProvidier: self.dummyAPIProvider())
        expect(viewModel.loggedIn).first == false
        viewModel.loggedIn.accept(true)
        viewModel.loadPlaylistTrigger.onNext(())
//        expect(viewModel.playlists).toEventually(BehaviorRelay<[Playlist]>(value: self.dummyPlaylist()), timeout: 0, pollInterval: 0, description: nil)
    }
    
    func testSimpleRxViewModel() {
        let viewModel = SimpleRxViewModel(apiProvidier: self.dummyAPIProvider())
        expect(viewModel.loggedIn).first == false
        
        
        let fakeLoadPlaylistInput = PublishSubject<Void>()
        fakeLoadPlaylistInput
            .bind(to: viewModel.loadPlaylistTrigger)
            .disposed(by: bag)
        
        fakeLoadPlaylistInput.onNext(())
        let element = try! viewModel.playlists.toBlocking().first()!
        XCTAssertTrue(element.count == 0)
        
        XCTAssertFalse(viewModel.playlists.value.count > 0)
        
        let fakeInput = PublishSubject<Void>()
        fakeInput
            .bind(to: viewModel.authorizedTrigger)
            .disposed(by: bag)
        
        fakeInput.onNext(())
        XCTAssertTrue(viewModel.loggedIn.value == true)
        XCTAssertFalse(viewModel.playlists.value.count > 0)
        
        fakeLoadPlaylistInput.onNext(())
        
        XCTAssertTrue(viewModel.playlists.value.count == 1)
        
        fakeLoadPlaylistInput.onNext(())
        
        XCTAssertTrue(viewModel.playlists.value.count == 1)
    }

    
    func testSimpleRxViewModel_v2 () {
        
        let expectation = self.expectation(description: "Test Playlists")
        
        let testScheduler = TestScheduler(initialClock: 0)
        let apiProvider = dummyAPIProvider()
        apiProvider.hasMore = true
        let viewModel = SimpleRxViewModel(apiProvidier: apiProvider)
        
        let fakeInput = PublishSubject<Void>()
        fakeInput
            .bind(to: viewModel.authorizedTrigger)
            .disposed(by: bag)
        
        fakeInput.onNext(())
        XCTAssertTrue(viewModel.loggedIn.value == true)
        
        
        var count = 0
        viewModel.playlists
            .subscribe(onNext: { list in
                count += 1
                print("\(count)")
                if list.count == 2 {
                    expectation.fulfill()
                }
            })
            .disposed(by: bag)
        
        let fakeLoadPlaylistInput = testScheduler.createHotObservable([Recorded.next(10, ()), Recorded.next(50, ())])
        fakeLoadPlaylistInput
            .bind(to: viewModel.loadPlaylistTrigger)
            .disposed(by: bag)
        
        testScheduler.createHotObservable([Recorded.next(20, false)])
            .bind(to: viewModel.loading)
            .disposed(by: bag)
        testScheduler.start()
        
        waitForExpectations(timeout: 10, handler: { _ in
            let elements = viewModel.playlists.value
            XCTAssertEqual(elements,
                           [Playlist(identifier: "1", title: "1", images: [] as [ImageMetadata]),
                            Playlist(identifier: "1", title: "1", images: [] as [ImageMetadata])])
        })
    }
}

extension RxSwiftPracticeTests {
    func dummyAPIProvider () -> APIProvider {
        let dummySongs = self.dummySongs()
        let dummyPlaylist = self.dummyPlaylist()
        return APIProvider(songs: dummySongs, playlist: dummyPlaylist)
    }
    
    
    func dummySongs() -> [Song] {
        return [
            Song(identifier: "1", name: "1", duration: 1, url: "1", album: Album(identifier: "1", name: "1", url: "1", images: [], artist: Artist(identifier: "1", name: "1", url: "1", images: []))),
            Song(identifier: "2", name: "2", duration: 2, url: "2", album: Album(identifier: "2", name: "2", url: "2", images: [], artist: Artist(identifier: "2", name: "2", url: "2", images: [])))
        ]
    }
    
    func dummyPlaylist() -> [Playlist] {
        return [Playlist(identifier: "1", title: "1", images: [])]
    }
}


internal class APIProvider: APIEngineActionsProtocol {
    private(set) var loggedin = false
    var hasMore = false
    let songs: [Song]
    let playlist: [Playlist]
    init(songs: [Song], playlist: [Playlist]) {
        self.songs = songs
        self.playlist = playlist
    }
    func authorizeKKBOX() -> Completable {
        return Completable.create(subscribe: { complete in
            complete(.completed)
            return Disposables.create()
        }).do(onError: nil, onCompleted: { self.loggedin = true })
    }
    
    func fetchFeaturedPlaylistTracks(with identifier: String) -> Single<[Song]> {
        if !loggedin {
            return Single.error(APIEngineError.invalidResponse)
        }
        return Single.just(songs)
    }
    
    func fetchFeaturedPlaylist(page: Int) -> Single<([Playlist], Bool)> {
        if !loggedin {
            return Single.error(APIEngineError.invalidResponse)
        }
        return Single.just((playlist, hasMore))
    }
}
