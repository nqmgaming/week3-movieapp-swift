import Foundation
import RxSwift
import RxCocoa

class MovieViewModel {
    private let movieService: MovieService
    private let disposeBag = DisposeBag()

    // Outputs
    let movies = PublishSubject<ListMovies>()
    let watchListMovies = PublishSubject<ListMovies>()
    let favoriteMovies = PublishSubject<ListMovies>()
    let movieDetail = PublishSubject<Movie>()
    let movieVideos = PublishSubject<Videos>()
    let updateWatchListSuccess = PublishSubject<(Bool, Bool)>()
    let updateFavoriteSuccess = PublishSubject<(Bool, Bool)>()
    let errors = PublishSubject<Error>()

    init(movieService: MovieService) {
        self.movieService = movieService
    }

    func fetchMovies(page: Int = 1) {
        movieService.fetchTrendingMovies(page: page)
            .subscribe(onSuccess: { movies in
                self.movies.onNext(movies)
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchWatchListMovies() {
        movieService.fetchWatchListMovies()
            .subscribe(onSuccess: { movies in
                self.watchListMovies.onNext(movies)
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchFavoriteMovies() {
        movieService.fetchFavoriteMovies()
            .subscribe(onSuccess: { movies in
                self.favoriteMovies.onNext(movies)
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchMovieDetail(movieID: Int) {
        movieService.fetchMovieDetail(movieID: movieID)
            .subscribe(onSuccess: { movie in
                self.movieDetail.onNext(movie)
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchMovieVideos(movieID: Int) {
        movieService.fetchMovieVideos(movieID: movieID)
            .subscribe(onSuccess: { videos in
                self.movieVideos.onNext(videos)
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func updateWatchListMovies(movie: Movie, watchlist: Bool, isRemoved: Bool = false) {
        movieService.updateWatchListMovies(movie: movie, watchlist: watchlist)
            .subscribe(onSuccess: { isSuccess in
                if isRemoved {
                    if let watchListData = UserDefaults.standard.data(forKey: "watchlist") {
                        var watchListMovies = try? JSONDecoder().decode([Movie].self, from: watchListData)
                        watchListMovies = watchListMovies?.filter { $0.id != movie.id }
                        if let encoded = try? JSONEncoder().encode(watchListMovies) {
                            UserDefaults.standard.set(encoded, forKey: "watchlist")
                        }
                    }
                } else {
                    if let watchListData = UserDefaults.standard.data(forKey: "watchlist") {
                        var watchListMovies = try? JSONDecoder().decode([Movie].self, from: watchListData)
                        watchListMovies?.append(movie)
                        if let encoded = try? JSONEncoder().encode(watchListMovies) {
                            UserDefaults.standard.set(encoded, forKey: "watchlist")
                        }
                    }
                }
                self.updateWatchListSuccess.onNext((isSuccess, watchlist))
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func updateFavoriteMovies(movie: Movie, favorite: Bool) {
        movieService.updateFavoriteMovies(movie: movie, favorite: favorite)
            .subscribe(onSuccess: { isSuccess in
                if favorite {
                    if let favoriteData = UserDefaults.standard.data(forKey: "favorite") {
                        var favoriteMovies = try? JSONDecoder().decode([Movie].self, from: favoriteData)
                        favoriteMovies?.append(movie)
                        if let encoded = try? JSONEncoder().encode(favoriteMovies) {
                            UserDefaults.standard.set(encoded, forKey: "favorite")
                        }
                    }
                } else {
                    if let favoriteData = UserDefaults.standard.data(forKey: "favorite") {
                        var favoriteMovies = try? JSONDecoder().decode([Movie].self, from: favoriteData)
                        favoriteMovies = favoriteMovies?.filter { $0.id != movie.id }
                        if let encoded = try? JSONEncoder().encode(favoriteMovies) {
                            UserDefaults.standard.set(encoded, forKey: "favorite")
                        }
                    }
                }
                self.updateFavoriteSuccess.onNext((isSuccess, favorite))
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
