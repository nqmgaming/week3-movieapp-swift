import Foundation
import Alamofire

class APIManager: MovieService {

    func fetchTrendingMovies(page: Int = 1, completion: @escaping (Swift.Result<ListMovies, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json"
        ]

        let url = "\(Constants.BASE_URL)/trending/movie/week?&page=\(page)&api_key=\(Constants.API_KEY)"

        AF.request(url, headers: headers).responseDecodable(of: ListMovies.self) { response in
            switch response.result {
                case .success(let listMovies):
                    completion(.success(listMovies))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    func fetchWatchListMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": "\(Constants.TOKEN)"
        ]

        let url = "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/watchlist/movies"

        AF.request(url, headers: headers).responseDecodable(of: ListMovies.self) { response in
            switch response.result {
                case .success(let listMovies):
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(listMovies.results) {
                        UserDefaults.standard.set(encoded, forKey: "watchlist")
                    }
                    completion(.success(listMovies))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    func fetchFavoriteMovies(completion: @escaping (Swift.Result<ListMovies, any Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": "\(Constants.TOKEN)"
        ]

        let url = "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/favorite/movies"

        AF.request(url, headers: headers).responseDecodable(of: ListMovies.self) { response in
            switch response.result {
                case .success(let listMovies):
                    completion(.success(listMovies))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }

    }

    func fetchMovieDetail(movieID: Int, completion: @escaping (Swift.Result<Movie, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json"
        ]

        let url = "\(Constants.BASE_URL)/movie/\(movieID)?api_key=\(Constants.API_KEY)"

        AF.request(url, headers: headers).responseDecodable(of: Movie.self) { response in
            switch response.result {
                case .success(let movie):
                    completion(.success(movie))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    func updateWatchListMovies(movie: Movie, watchlist: Bool, completion: @escaping (Swift.Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": "\(Constants.TOKEN)"
        ]

        let url = "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/watchlist"
        print(url)

        let parameters: [String: Any] = [
            "media_type": "movie",
            "media_id": movie.id,
            "watchlist": watchlist
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UpdateWatchListResponse.self) { response in
            switch response.result {
                case .success(let result):
                    completion(.success(result.success))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    func fetchMovieVideos(movieID: Int, completion: @escaping (Swift.Result<Videos, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json"
        ]

        let url = "\(Constants.BASE_URL)/movie/\(movieID)/videos?api_key=\(Constants.API_KEY)"

        AF.request(url, headers: headers).responseDecodable(of: Videos.self) { response in
            switch response.result {
                case .success(let videos):
                    completion(.success(videos))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    func updateFavoriteMovies(movie: Movie, favorite: Bool, completion: @escaping (Swift.Result<Bool, any Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": "\(Constants.TOKEN)"
        ]

        let url = "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/favorite"

        let parameters: [String: Any] = [
            "media_type": "movie",
            "media_id": movie.id,
            "favorite": favorite
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UpdateWatchListResponse.self) { response in
            switch response.result {
                case .success(let result):
                    completion(.success(result.success))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }
}
