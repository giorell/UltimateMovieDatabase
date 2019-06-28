//
//  MDProfile.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/19/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import Foundation


struct MDProfile: Codable {
    
    let avatar: avatar
    let id: Int
    let iso6391: String?
    let iso31661: String?
    let name: String
    let includeAdult: Bool?
    let username: String
    
    enum Codingkeys: String, CodingKey {
        case avatar
        case id
        case iso6391 = "iso_639_1"
        case iso31661 = "iso_3166_1"
        case name
        case includeAdult = "include_adult"
        case username
    }
}

struct avatar: Codable {
    
    let gravatar: gravatar
    
    enum CodingKeys: String, CodingKey {
        case gravatar
    }
}

struct gravatar: Codable {
    
    let hash: String
    
    enum CodingKeys: String, CodingKey {
        case hash
    }
}
