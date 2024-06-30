//
//  Video.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 30/6/24.
//

import Foundation

import Foundation

// MARK: - Video
struct Videos: Codable {
    let id: Int
    let results: [Result]

    func getVideoURL() -> URL? {
        let type = results.first?.type ?? ""

        // if type is Trailer return, and if not have any thing else return frist Teaser and if not return first
        let video = results.first { $0.type == "Trailer" } ?? results.first { $0.type == "Teaser" } ?? results.first

        if type == "Trailer" || type == "Teaser" {
            return URL(string: "https://www.youtube.com/watch?v=\(video?.key ?? "")")
        } else {
            return URL(string: "https://www.youtube.com/watch?v=\(video?.key ?? "")")
        }

    }
}

// MARK: - Result
struct Result: Codable {
    let iso639_1, iso3166_1, name, key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let publishedAt, id: String

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}
