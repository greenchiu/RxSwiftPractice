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

class RxSwiftPracticeTests: XCTestCase {

    
    
    func test() {
        let viewModel = SimpleRxViewModel(apiProvidier: self.dummyAPIProvider())
        expect(viewModel.loggedIn).first == false
        viewModel.loggedIn.accept(true)
        viewModel.loadPlaylistTrigger.onNext(())
        expect(viewModel.playlists).toEventually(BehaviorRelay<[Playlist]>(value: self.dummyPlaylist()), timeout: 0, pollInterval: 0, description: nil)
    }

}

extension RxSwiftPracticeTests {
    func dummyAPIProvider () -> APIEngineActionsProtocol {
        let dummySongs = self.dummySongs()
        let dummyPlaylist = self.dummyPlaylist()
        struct APIProvider: APIEngineActionsProtocol {
            let songs: [Song]
            let playlist: [Playlist]
            func authorizeKKBOX() -> Completable {
                return Completable.create(subscribe: { complete in
                    complete(.completed)
                    return Disposables.create()
                })
            }
            
            func fetchFeaturedPlaylistTracks(with identifier: String) -> Single<[Song]> {
                return Single.just(songs)
            }
            
            func fetchFeaturedPlaylist(page: Int) -> Single<([Playlist], Bool)> {
                return Single.just((playlist, false))
            }
        }
        
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


