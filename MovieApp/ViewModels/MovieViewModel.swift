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
    let searchListMovie = PublishSubject<ListMovies>()
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

    func searchMovies(query: String, page: Int = 1) {
        movieService.searchMovies(query: query, page: page)
            .subscribe(onSuccess: { movies in
                self.searchListMovie.onNext(movies)
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func updateWatchListMovies(movie: Movie, watchlist: Bool, isRemoved: Bool = false) {
        movieService.updateWatchListMovies(movie: movie, watchlist: watchlist)
            .subscribe(onSuccess: { isSuccess in
                self.updateWatchListSuccess.onNext((isSuccess, watchlist))
                self.fetchWatchListMovies()
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func updateFavoriteMovies(movie: Movie, favorite: Bool) {
        movieService.updateFavoriteMovies(movie: movie, favorite: favorite)
            .subscribe(onSuccess: { isSuccess in
                self.updateFavoriteSuccess.onNext((isSuccess, favorite))
                self.fetchFavoriteMovies()
            }, onFailure: { error in
                self.errors.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
