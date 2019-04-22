//
//  HomeViewModel.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/22.
//  Copyright © 2019 Green. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel {
    private let apiProvider = APIEngine.shared
    private var page: Int = 0
    
    
    private let bag = DisposeBag()
    let startTrigger = PublishSubject<Void>()
    let fetchMoreTrigger = PublishSubject<Void>()
    let result = BehaviorSubject<[Playlist]>(value: [])
    
    let error = PublishSubject<String>()
    
    let running = Variable<Bool>(false)
    
    let hasMore = Variable<Bool>(true)
    
    init() {
        buildObserables()
    }
    
    func buildObserables() {
        
        let authorizeRequest = running
                        .asObservable()
                        .sample(startTrigger)
                        .flatMap { _ -> Observable<Void> in
                            Observable.empty()
                        }
        
        let authorizedResponse = authorizeRequest.flatMap { _ -> Single<([Playlist], Bool)> in
            return self.apiProvider.fetchFeaturedPlaylist(page: self.page)
        }
        
        let fetchMoreRequest = running
            .asObservable()
            .sample(fetchMoreTrigger)
            .flatMap { _ -> Observable<Void> in
                if self.hasMore.value {
                    self.page += 1
                }
                return Observable.empty()
            }
        
        let fetchResponse = fetchMoreRequest.flatMap{ _ -> Single<([Playlist], Bool)> in
            return self.apiProvider.fetchFeaturedPlaylist(page: self.page)
        }
        
        Observable.of(authorizedResponse, fetchResponse)
            .merge()
            .do(onNext: { (playlists, hasMore) in
                self.hasMore.value = hasMore
            })
            .share()
            .flatMap { (playlists, _) -> Observable<[Playlist]> in
                return Observable.just(playlists)
            }
            .bind(to: result)
            .disposed(by: bag)
        
        
        Observable
            .merge(authorizeRequest.map{ _ in return true},
                  fetchMoreRequest.map{ _ in return false})
            .share(replay: 1)
            .bind(to: running)
            .disposed(by: bag)
    }
}
