//
//  ServerResponse.swift
//  BigHM
//
//  Created by Майя Герасимова on 06.12.2020.
//

import Foundation

struct ServerResponse<Object: Decodable>: Decodable {
    var hits: [Object]
}
