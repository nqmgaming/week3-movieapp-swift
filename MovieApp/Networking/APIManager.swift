import Foundation
import Alamofire
import RxSwift

class APIManager: MovieService {
    func searchMovies(query: String, page: Int) -> RxSwift.Single<ListMovies> {
        return Single.create { single in
            let headers: HTTPHeaders = [
                "accept": "application/json"
            ]

            let url = "\(Constants.BASE_URL)/search/movie?query=\(query)&page=\(page)&api_key=\(Constants.API_KEY)"

            AF.request(url, headers: headers).responseDecodable(of: ListMovies.self) { response in
                switch response.result {
                    case .success(let listMovies):
                        single(.success(listMovies))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    

    func fetchTrendingMovies(page: Int = 1) -> Single<ListMovies> {
        return Single.create { single in
            let headers: HTTPHeaders = [
                "accept": "application/json"
            ]

            let url = "\(Constants.BASE_URL)/trending/movie/week?&page=\(page)&api_key=\(Constants.API_KEY)"

            AF.request(url, headers: headers).responseDecodable(of: ListMovies.self) { response in
                switch response.result {
                    case .success(let listMovies):
                        single(.success(listMovies))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetchWatchListMovies() -> Single<ListMovies> {
        return Single.create { single in
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
                        single(.success(listMovies))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetchFavoriteMovies() -> Single<ListMovies> {
        return Single.create { single in
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "content-type": "application/json",
                "Authorization": "\(Constants.TOKEN)"
            ]

            let url = "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/favorite/movies"

            AF.request(url, headers: headers).responseDecodable(of: ListMovies.self) { response in
                switch response.result {
                    case .success(let listMovies):
                        single(.success(listMovies))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetchMovieDetail(movieID: Int) -> Single<Movie> {
        return Single.create { single in
            let headers: HTTPHeaders = [
                "accept": "application/json"
            ]

            let url = "\(Constants.BASE_URL)/movie/\(movieID)?api_key=\(Constants.API_KEY)"

            AF.request(url, headers: headers).responseDecodable(of: Movie.self) { response in
                switch response.result {
                    case .success(let movie):
                        single(.success(movie))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetchMovieVideos(movieID: Int) -> Single<Videos> {
        return Single.create { single in
            let headers: HTTPHeaders = [
                "accept": "application/json"
            ]

            let url = "\(Constants.BASE_URL)/movie/\(movieID)/videos?api_key=\(Constants.API_KEY)"

            AF.request(url, headers: headers).responseDecodable(of: Videos.self) { response in
                switch response.result {
                    case .success(let videos):
                        single(.success(videos))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func updateWatchListMovies(movie: Movie, watchlist: Bool) -> Single<Bool> {
        return Single.create { single in
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
                        single(.success(result.success))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func updateFavoriteMovies(movie: Movie, favorite: Bool) -> Single<Bool> {
        return Single.create { single in
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
                        single(.success(result.success))
                    case .failure(let error):
                        print(error.localizedDescription)
                        single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
