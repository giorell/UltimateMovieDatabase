//
//  PostSession.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import Foundation

struct PostSession: Codable {
    
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
    
}
