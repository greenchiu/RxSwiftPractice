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
    
    let playlists = BehaviorRelay<[Playlist]>(value: [])
    let loggedIn = BehaviorRelay<Bool>(value: false)
    
    init() {
        
    }
    
    func startAuthorizing() {
        authorize()
            .subscribe(onCompleted: {
                self.loggedIn.accept(true)
            }, onError: { _ in
                
            })
            .disposed(by: bag)
    }
    
    private func authorize() -> Completable {
        return api.authorizeKKBOX()
    }
    
    func fetchMore() {
        
    }
    
    private func fetchPlaylist() -> Single<[Playlist]> {
        return api.fetchFeaturedPlaylist(page: page)
            .do(onSuccess: { (argument) in
                let (_, hasMore) = argument
                if hasMore {
                    self.page += 1
                }
            })
            .flatMap { (argument) -> Single<[Playlist]> in
            let (playlists, _) = argument
            return Single.just(playlists)
        }
    }
}
