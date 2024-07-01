
import Foundation

// MARK: - ListMovies
struct ListMovies: Codable {
    let page: Int?
    let results: [Movie]?
    let totalPages, totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Result
struct Movie: Codable {
    let adult: Bool?
    let backdropPath: String?
    let genreIds: [Int]?
    let id: Int
    let mediaType, originalLanguage, originalTitle, overview: String?
    let popularity: Double?
    let posterPath, releaseDate, title: String?
    let video: Bool?
    let voteAverage: VoteAverage
    let voteCount: Int?
    let runtime: Int?

    var posterURL: URL? {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")
    }

    var backdropURL: URL? {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")
    }

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case runtime
    }

    func getVoteAverage() -> String {
        switch voteAverage {
            case .double(let value):
                return String(format: "%.1f", value)
            case .integer(let value):
                return String(value)
        }
    }

    func getTitle() -> String {
        return title ?? originalTitle ?? ""
    }

    func getReleaseDate() -> String {
        return releaseDate ?? ""
    }

    func getRuntime() -> String {
        guard let runtime = runtime else {
            return ""
        }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)min"
    }

    func getFormatDate() -> String {
        // Example: 2021-06-24 -> 24 June 2021
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: releaseDate ?? "") {
            formatter.dateFormat = "dd MMMM yyyy"
            return formatter.string(from: date)
        }
        return ""
    }

    func getDesc() -> String {
        if overview == "" {
            return "No description available"
        }
        return "Description: \(overview ?? "")"
    }

    func getRatingStar() -> Double {
        switch voteAverage {
            case .double(let value):
                return value / 2
            case .integer(let value):
                return Double(value) / 2
        }
    }
}

// MARK: - VoteAverage
enum VoteAverage: Codable {
    case double(Double)
    case integer(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else {
            throw DecodingError.typeMismatch(VoteAverage.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Double or Int"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .double(let value):
                try container.encode(value)
            case .integer(let value):
                try container.encode(value)
        }
    }
}
