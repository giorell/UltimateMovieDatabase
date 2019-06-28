//
//  LogoutRequest.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import Foundation

struct LogoutRequest: Codable {
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}
