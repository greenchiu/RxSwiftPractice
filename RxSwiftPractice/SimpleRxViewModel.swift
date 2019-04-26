//
//  SimpleRxViewModel.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/22.
//  Copyright © 2019 Green. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SimpleRxViewModel {
    private let bag = DisposeBag()
    private let api: APIEngineActionsProtocol
    private(set) var page = 0
    private(set) var hasMore = false
    
    let authorizedTrigger = PublishSubject<Void>()
    
    let loadPlaylistTrigger = PublishSubject<Void>()
    let playlists = BehaviorRelay<[Playlist]>(value: [])
    let loggedIn = BehaviorRelay<Bool>(value: false)
    let loading = BehaviorRelay<Bool>(value: false)
    
    init(apiProvidier: APIEngineActionsProtocol = APIEngine.shared) {
        api = apiProvidier
        let authorizedRequest = Observable.combineLatest(loading.asObservable(), loggedIn.asObservable())
            .sample(authorizedTrigger)
            .filter { isLoading, isLoggedIn in
                return !isLoading && !isLoggedIn
            }
        
        let authorizedResponse = authorizedRequest
            .flatMap { _ -> Completable in
                self.api.authorizeKKBOX().do(onError: { _ in
                    self.loading.accept(false)
                    self.loggedIn.accept(false)
                }, onCompleted:{
                    self.hasMore = true
                    self.loading.accept(false)
                    self.loggedIn.accept(true)
                })
            }
        
        authorizedResponse
            .subscribe { _ in
                /*
                 *  Do nothing. Actually, it doesn't work.
                 *  Add this subscribe to invoke the do action at above flatMap clourse
                 */
                print("Hello guys, you can't see this message.")
            }
            .disposed(by: bag)
        
        let playlistRequest = fetchPlaylistRequest().share(replay: 1)
        
        let playlistResponse = playlistRequest.flatMap { page in
            self.api.fetchFeaturedPlaylist(page: page)
        }
            .do(onNext: { argument in
                let (_, hasMore) = argument
                self.hasMore = hasMore
                self.page += 1
            })
            .share(replay: 1)
        
        playlistResponse.map { [unowned self] argument in
            let (newPlaylists, _) = argument
            let finalPlaylists = self.playlists.value + newPlaylists
            return finalPlaylists
        }
        .bind(to: playlists)
        .disposed(by: bag)
        
        Observable.merge(
            authorizedRequest.map { _ in true },
            playlistRequest.map { _ in true },
            playlistResponse.map{ _ in false },
            authorizedResponse.map { _ in false })
            .bind(to: loading)
            .disposed(by: bag)
    }
    
    private func authorize() -> Completable {
        return api.authorizeKKBOX()
    }
    
    private func fetchPlaylistRequest() -> Observable<Int> {
        return loading
            .asObservable()
            .sample(loadPlaylistTrigger)
            .filter { _ in self.hasMore && self.loggedIn.value }
            .flatMap { isLoading -> Observable<Int> in
                if isLoading {
                    return Observable.empty()
                }
                return Observable.just(self.page)
            }
    }
}
