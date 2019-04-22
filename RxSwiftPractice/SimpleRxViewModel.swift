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
    private let api = APIEngine.shared
    private(set) var page = 0
    private(set) var hasMore = false
    private var authorizeAction: Completable!
    
    let authorizedTrigger = PublishSubject<Void>()
    
    let playlists = BehaviorRelay<[Playlist]>(value: [])
    let loggedIn = BehaviorRelay<Bool>(value: false)
    let loading = BehaviorRelay<Bool>(value: false)
    
    init() {
        
        let authorizedRequest = Observable.of(request())
        
        authorizeAction = authorizedRequest
            .do(onNext: { _ in
                self.loading.accept(true)
            })
            .flatMap { _ -> Completable in
                return self.api.authorizeKKBOX()
            }
            .ignoreElements()
        
        // How to bind the request and reponse to `loading` ??
        // If I add the observer here, it will execute the authorization flow immediately
        // But I hope it could be trigger by the authorizedTrigger
        // How can I approach it?
//        Observable.merge(
//            authorizedRequest.map{ _ in true},
//            authorizeAction.asObservable().map { _ in false })
//            .share(replay: 1)
//            .bind(to: loading)
//            .disposed(by: bag)
    }
    
    func startAuthorizing() {
        authorizeAction
            .subscribe { event in
                switch event {
                case .completed:
                    self.loggedIn.accept(true)
                    self.hasMore = true
                default:
                    break
                }
                self.loading.accept(false)
            }
            .disposed(by: bag)
    }
    
    private func request() -> Observable<Void> {
        return loading
                .asObservable()
                .flatMap { _ in
                    Observable.empty()
                }
    }
    
    private func authorize() -> Completable {
        return api.authorizeKKBOX()
    }
    
    func fetchMore() {
        guard self.hasMore else {
            return
        }
        fetchPlaylist()
            .subscribe { event in
                self.loading.accept(false)
                switch event {
                case .success(let playlists):
                    let newPlaylists = self.playlists.value + playlists
                    self.playlists.accept(newPlaylists)
                default:
                    break
                }
            }
            .disposed(by: bag)
    }
    
    private func fetchPlaylist() -> Single<[Playlist]> {
        return Observable.of(page)
            .do(onNext: { _ in
                self.loading.accept(true)
            })
            .flatMap { page -> Single<([Playlist], Bool)> in
                self.api.fetchFeaturedPlaylist(page: page)
            }
            .do(onNext: { (argument) in
                let (_, hasMore) = argument
                if hasMore {
                    self.page += 1
                }
                self.hasMore = hasMore
            })
            .asSingle()
            .flatMap { (argument) -> Single<[Playlist]> in
                let (playlists, _) = argument
                return Single.just(playlists)
            }
            .catchErrorJustReturn([])
    }
}
