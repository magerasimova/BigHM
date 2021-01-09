//
//  ImageInfo.swift
//  BigHM
//
//  Created by Майя Герасимова on 06.12.2020.
//

import Foundation

struct ImageInfo: Decodable {
    var id: Int
    var favorites: Int?
    var Likes: Int?
    var downloads: Int?
    var previewURL: URL?
    var webformatURL: URL?
    var views: Int?
    var tags: String?
}
