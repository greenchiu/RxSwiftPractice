//
//  APIEngineActionsProtocol.swift
//  RxSwiftPractice
//
//  Created by Green on 2019/4/26.
//  Copyright © 2019 Green. All rights reserved.
//

import Foundation
import RxSwift

enum APIEngineError: Error {
    case invalidResponse
}

protocol APIEngineActionsProtocol {
    func authorizeKKBOX() -> Completable
    func fetchFeaturedPlaylist(page: Int) -> Single<([Playlist], Bool)>
    func fetchFeaturedPlaylistTracks(with identifier: String) -> Single<[Song]> 
}


