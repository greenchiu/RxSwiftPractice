//
//  PlaylistSongViewModel.swift
//  RxSwiftPractice
//
//  Created by Green on 2019/4/22.
//  Copyright © 2019 Green. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



class PlaylistSongViewModel: PlaylistSongViewModelProtocols {
    private let apiProvider = APIEngine.shared
    private var page: Int = 0
    private let bag = DisposeBag()
    
    let songs = BehaviorRelay<[Song]>(value: [])
    let loading = BehaviorRelay<Bool>(value: false)
    let trigger = PublishSubject<Void>()
    
    
    init(playlistIdentifier: String) {
        
        let requests = request(subject: trigger)
                        .share(replay: 1)
        
        let response = requests.flatMap { _ in
            self.apiProvider.fetchFeaturedPlaylistDetial(with: playlistIdentifier)
        }
        .share(replay: 1)
        
        response
            .catchErrorJustReturn([])
            .debug("start fetch songs", trimOutput: true)
            .bind(to: songs)
            .disposed(by: bag)
        
        
        Observable.of(requests.map{_ in true},
                      response.map{_ in false})
            .merge()
            .share(replay: 1)
            .bind(to: loading)
            .disposed(by: bag)
    }
    
    private func request<T>(subject: PublishSubject<T>) -> Observable<Int> {
        return loading
            .asObservable()
            .sample(subject)
            .flatMap { isLoading -> Observable<Int> in
                if isLoading {
                    return Observable.empty()
                }
                return Observable.just(0)
        }
    }
    
    
}
