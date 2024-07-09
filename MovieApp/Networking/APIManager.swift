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
        // fetch from nsuserdefaults
        return Single.create { single in
            // get from userdefaults
            let movies = UserDefaults.standard.getWatchListMovies()
            let listMovies = ListMovies(page: 1, results: movies, totalPages: 1, totalResults: movies.count)
            single(.success(listMovies))
            return Disposables.create()
        }
    }

    func fetchFavoriteMovies() -> Single<ListMovies> {
        return Single.create { single in
            // get from userdefaults
            let movies = UserDefaults.standard.getFavoriteMovies()
            let listMovies = ListMovies(page: 1, results: movies, totalPages: 1, totalResults: movies.count)
            single(.success(listMovies))
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
            // save to userdefaults
            var movies = UserDefaults.standard.getWatchListMovies()
            if watchlist && !movies.contains(where: { $0.id == movie.id }) {
                movies.append(movie)
            } else {
                movies.removeAll { $0.id == movie.id }
            }
            UserDefaults.standard.setWatchListMovies(movies)
            single(.success(true))
            return Disposables.create()
        }
    }

    func updateFavoriteMovies(movie: Movie, favorite: Bool) -> Single<Bool> {
        return Single.create { single in
            // save to userdefaults
            var movies = UserDefaults.standard.getFavoriteMovies()
            if favorite  && !movies.contains(where: { $0.id == movie.id }) {
                movies.append(movie)
            } else {
                movies.removeAll { $0.id == movie.id }
            }
            UserDefaults.standard.setFavoriteMovies(movies)
            single(.success(true))
            return Disposables.create()
        }
    }
}
