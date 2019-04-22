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

enum APIEngineError: Error {
    case invalidResponse
}

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
    
    private(set) var loggedin: Bool = false
    
    private override init() {}
    
    final internal func response( request: URLRequest ) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return session.rx.response(request: request)
    }
}

extension APIEngine {
    
    private func request(URLString: String) -> URLRequest {
        var request = URLRequest(url: URL(string: URLString)!)
        request.allHTTPHeaderFields = self.kkbox?.apiHTTPHeaders
        return request
    }
    
    func authorizeKKBOX() -> Completable {
        var request = URLRequest(url: KKBOX.authorizedUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = KKBOX.authorizedPostData
        
        return response(request: request).do(onNext: { _, data in
            self.kkbox = try JSONDecoder().decode(KKBOX.self, from: data)
            self.loggedin = true
        }).ignoreElements()
    }
    
    func fetchFeaturedPlaylist(page: Int = 0) -> Single<([Playlist], Bool)> {
        let pageCount = 200
        let aRequest = request(URLString: "https://api.kkbox.com/v1.1/featured-playlists?territory=TW&offset=\(page * pageCount)&limit=\(pageCount)")
        return session.rx.json(request: aRequest)
            .asSingle()
            .map { dict in
                guard
                    let dictionary = dict as? [String: Any],
                    let data = dictionary["data"] as? [[String: Any]],
                    let pagination = dictionary["paging"] as? [String: Any?],
                    let playlists = try? JSONDecoder().decode([Playlist].self, from: JSONSerialization.data(withJSONObject: data))
                    else {
                        throw APIEngineError.invalidResponse
                }
                
                var hasNextPage = false
                if let next = pagination["next"], let _ = next {
                    hasNextPage = true
                }
                return (playlists, hasNextPage)
            }
    }
    
    func fetchFeaturedPlaylistDetial(with identifier: String) -> Single<[Song]> {
        let aRequest = request(URLString: "https://api.kkbox.com/v1.1/shared-playlists/\(identifier)/tracks?territory=TW&offset=0&limit=500")
        return session.rx.json(request: aRequest)
            .asSingle()
            .map { dict in
                guard
                    let dictionary = dict as? [String: Any],
                    let data = dictionary["data"] as? [[String: Any]],
                    let songs = try? JSONDecoder().decode([Song].self, from: JSONSerialization.data(withJSONObject: data))
                    else {
                        throw APIEngineError.invalidResponse
                }
                return songs
            }
    }
}

extension APIEngine: URLSessionDelegate {
    
}
