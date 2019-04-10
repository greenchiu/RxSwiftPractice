//
//  APIEngine.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/10.
//  Copyright © 2019 Green. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



private extension KKBOX {
    static let clientSecret = "e3eea435b0e83489972cc29d4e2f95cd"
    static let clientId = "3362d93392c8160469538817b46545c0"
    static let authorizedUrl = URL(string: "https://account.kkbox.com/oauth2/token")!
    static var authorizedPostData: Data {
        return "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)".data(using: .utf8)!
    }
}

class APIEngine: NSObject {
    static let shared = APIEngine()
    
    private let disposeBag = DisposeBag()
    
    private(set) lazy var session: URLSession = {
        let aSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        return aSession
    }()
    
    private var kkbox:KKBOX?
    
    private override init() {}
    
    final internal func response( request: URLRequest ) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return session.rx.response(request: request)
    }
}

extension APIEngine {
    func authorizeKKBOX() -> Completable {
        var request = URLRequest(url: KKBOX.authorizedUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = KKBOX.authorizedPostData
        
        return response(request: request).do(onNext: { _, data in
            self.kkbox = try JSONDecoder().decode(KKBOX.self, from: data)
        }).ignoreElements()
    }
    
    func fetchFeaturedPlaylist(page: Int = 0) -> Single<([Playlist], Bool)> {
        let pageCount = 200
        var request = URLRequest(url: URL(string: "https://api.kkbox.com/v1.1/featured-playlists?territory=TW&offset=\(page * pageCount)&limit=\(pageCount)")!)
        request.allHTTPHeaderFields = self.kkbox?.apiHTTPHeaders
        return Single.create(subscribe: { single in
            self.session.rx.json(request: request).subscribe(onNext: { anyDictionary in
                guard let dictionary = anyDictionary as? [String: Any] else {
                    return
                }
                guard
                    let data = dictionary["data"] as? [[String: Any]],
                    let pagination = dictionary["paging"] as? [String: Any?] else {
                    return
                }
                let playlists:[Playlist] = data.compactMap {
                    try? Playlist(dictionary: $0)
                }
                
                let nextPage: Bool = pagination["next"] != nil
                single(.success((playlists, nextPage)))
            }, onError: { error in
                single(.error(error))
            }).disposed(by: self.disposeBag)
            return Disposables.create()
        });
    }
}

extension APIEngine: URLSessionDelegate {
    
}
