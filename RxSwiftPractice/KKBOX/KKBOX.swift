//
//  KKBOX.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/10.
//  Copyright © 2019 Green. All rights reserved.
//

import Foundation

struct KKBOX: Codable {
    var token: String?
    var tokenType: String?
    
    var apiHTTPHeaders: [String: String]? {
        guard let token = token, let tokenTpye = tokenType else {
            return nil
        }
        return ["Authorization": "\(tokenTpye) \(token)",
            "Accept":"application/json"]
    }
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
    }
}

struct ImageMetadata: Codable {
    var height: Int
    var width: Int
    var url: String
}

struct Artist: Codable {
    var identifier: String
    var name: String
    var url: String
    var images: [ImageMetadata]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case images
        case url
    }
}

struct Album: Codable {
    var identifier: String
    var name: String
    var url: String
    var images: [ImageMetadata]
    var artist: Artist
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case images
        case url
        case artist
    }
}

struct Playlist: Codable {
    var identifier: String
    var title: String
    var images: [ImageMetadata]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title
        case images
    }
}

extension Playlist {
    init(dictionary: [String: Any]) throws {
        do {
            self = try JSONDecoder().decode(Playlist.self, from: JSONSerialization.data(withJSONObject: dictionary))
        }
        catch {
            throw error
        }
    }
}

struct Song: Codable {
    var identifier: String
    var name: String
    var duration: Double
    var url: String
    var album: Album
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case duration
        case url
        case album
    }
}
