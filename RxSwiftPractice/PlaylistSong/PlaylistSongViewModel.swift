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
    private let apiProvider: APIEngineActionsProtocol
    private var page: Int = 0
    private let bag = DisposeBag()
    
    let songs = BehaviorRelay<[Song]>(value: [])
    let loading = BehaviorRelay<Bool>(value: false)
    let trigger = PublishSubject<Void>()
    let error = BehaviorRelay<String>(value: "")
    
    init(playlistIdentifier: String, apiProvider: APIEngineActionsProtocol) {
        self.apiProvider = apiProvider
        let requests = request(subject: trigger)
                        .share(replay: 1)
        
        let response = requests.flatMap { _ in
                self.apiProvider.fetchFeaturedPlaylistTracks(with: playlistIdentifier)
            }
            .catchError { error in
                if error is APIEngineError {
                    self.error.accept("ApiEngineError")
                }
                else {
                    self.error.accept("Unknown Error")
                }
                return Observable.empty()
            }
            .share(replay: 1)
        
        response
            .bind(to: songs)
            .disposed(by: bag)
        
        
        Observable.of(requests.map{ _ in true },
                      response.map{ _ in false },
                      error.map{ _ in false })
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
