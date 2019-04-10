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

//"""
//{
//    "id": "Gr1u9_wJSVBLZejbWF",
//    "name": "愛的燈火",
//    "url": "https://event.kkbox.com/content/album/Gr1u9_wJSVBLZejbWF",
//    "explicitness": false,
//    "available_territories": [
//    "TW",
//    "HK",
//    "SG",
//    "MY"
//    ],
//    "release_date": "2017-07-26",
//    "images": [
//    {
//    "height": 160,
//    "width": 160,
//    "url": "https://i.kfs.io/album/global/27491421,0v2/fit/160x160.jpg"
//    },
//    {
//    "height": 500,
//    "width": 500,
//    "url": "https://i.kfs.io/album/global/27491421,0v2/fit/500x500.jpg"
//    },
//    {
//    "height": 1000,
//    "width": 1000,
//    "url": "https://i.kfs.io/album/global/27491421,0v2/fit/1000x1000.jpg"
//    }
//    ],
//    "artist": {
//        "id": "KldNiwYxd1n-AYVOv6",
//        "name": "朱海君",
//        "url": "https://event.kkbox.com/content/artist/KldNiwYxd1n-AYVOv6",
//        "images": [
//        {
//        "height": 160,
//        "width": 160,
//        "url": "https://i.kfs.io/artist/global/204079,0v2/fit/160x160.jpg"
//        },
//        {
//        "height": 300,
//        "width": 300,
//        "url": "https://i.kfs.io/artist/global/204079,0v2/fit/300x300.jpg"
//        }
//        ]
//    }
//}
//"""
