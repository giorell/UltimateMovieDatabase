//
//  MDModel.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import Foundation
import CoreData

class MovieModel {
    
    static var watchlist = [Movie]()
    static var favorites = [Movie]()
    static var trendingMovies = [Movie]()
    static var watchlistIDs = [Int]()
    static var favoritesIDs = [Int]()
    static var coreWatchlistMovies: [NSManagedObject] = []
    static var coreFavoriteMovies: [NSManagedObject] = []
    
}
