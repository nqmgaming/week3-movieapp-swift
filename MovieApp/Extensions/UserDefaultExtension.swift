//
//  NSUserExtension.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 8/7/24.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let watchlist = "watchlist"
        static let favorite = "favorite"
    }

    func setWatchListMovies(_ movies: [Movie]) {
        print("setWatchListMovies")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(movies) {
            set(encoded, forKey: UserDefaults.Keys.watchlist)
        }
    }

    func getWatchListMovies() -> [Movie] {
        print("getWatchListMovies")
        let decoder = JSONDecoder()
        if let movies = data(forKey: UserDefaults.Keys.watchlist) {
            if let decoded = try? decoder.decode([Movie].self, from: movies) {
                return decoded
            }
        }
        return []
    }

    func setFavoriteMovies(_ movies: [Movie]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(movies) {
            set(encoded, forKey: UserDefaults.Keys.favorite)
        }
    }

    func getFavoriteMovies() -> [Movie] {
        let decoder = JSONDecoder()
        if let movies = data(forKey: UserDefaults.Keys.favorite) {
            if let decoded = try? decoder.decode([Movie].self, from: movies) {
                return decoded
            }
        }
        return []
    }
}
