//
//  MovieViewModel.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

class MovieViewModel {
    private let movieService: MovieService
    weak var outputMovies: MovieViewModelOutput?
    weak var outputMovieDetail: MovieDetailViewModelOutput?
    weak var outputMovieVideos: MovieVideosViewModelOutput?
    weak var outputUpdateWatchListMovies: MovieUpdateWatchListViewModelOutput?
    weak var outputFavoriteMovies: MovieUpdateFavoriteViewModelOutput?

    init(movieService: MovieService) {
        self.movieService = movieService
    }

    func fetchTrendingMovies(page: Int = 1){
        movieService.fetchTrendingMovies(page: page){ result in
            switch result {
                case .success(let movies):
                    self.outputMovies?.didFetchMovies(movies: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovies?.didFailToFetchMovies(error: error)
            }
        }

        movieService.fetchWatchListMovies{ result in
            switch result {
                case .success(let movies):
                    // save watchlist movies to user defaults
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(movies.results) {
                        UserDefaults.standard.set(encoded, forKey: "watchlist")
                    }
                    self.outputMovies?.didFetchWatchListMovies(movies: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovies?.didFailToFetchMovies(error: error)
            }
        }

        movieService.fetchFavoriteMovies{ result in
            switch result {
                case .success(let movies):
                    // save favorite movies to user defaults
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(movies.results) {
                        UserDefaults.standard.set(encoded, forKey: "favorite")
                    }
                    self.outputMovies?.didFetchFavoriteMovies(movies: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovies?.didFailToFetchMovies(error: error)
            }
        }
    }

    func fetchMovieDetail(movieID: Int){
        movieService.fetchMovieDetail(movieID: movieID){ result in
            switch result {
                case .success(let movie):
                    self.outputMovieDetail?.didFetchMovieDetail(movie: movie)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovieDetail?.didFailToFetchMovieDetail(error: error)
            }
        }
    }

    func fetchMovieVideos(movieID: Int){
        movieService.fetchMovieVideos(movieID: movieID){ result in
            switch result {
                case .success(let videos):
                    self.outputMovieVideos?.didFetchMovieVideos(videos: videos)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovieVideos?.didFailToFetchMovieVideos(error: error)
            }
        }
    }

    func updateWatchListMovies(movie: Movie, watchlist: Bool, isRemoved: Bool = false){
        movieService.updateWatchListMovies(movie: movie, watchlist: watchlist){ result in
            switch result {
                case .success(let isSuccess):
                    // update watchlist in user defaults
                    if isRemoved {
                        if let watchlistData = UserDefaults.standard.data(forKey: "watchlist") {
                            var watchlistMovies = try? JSONDecoder().decode([Movie].self, from: watchlistData)
                            watchlistMovies = watchlistMovies?.filter { $0.id != movie.id }
                            if let encoded = try? JSONEncoder().encode(watchlistMovies) {
                                UserDefaults.standard.set(encoded, forKey: "watchlist")
                            }
                        }
                    } else {
                        if let watchlistData = UserDefaults.standard.data(forKey: "watchlist") {
                            var watchlistMovies = try? JSONDecoder().decode([Movie].self, from: watchlistData)
                            watchlistMovies?.append(movie)
                            if let encoded = try? JSONEncoder().encode(watchlistMovies) {
                                UserDefaults.standard.set(encoded, forKey: "watchlist")
                            }
                        }
                    }
                    self.outputUpdateWatchListMovies?.didUpdateWatchListMovies(isSuccess: isSuccess, isRemoved: isRemoved)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputUpdateWatchListMovies?.didFailToUpdateWatchListMovies(error: error)
            }
        }
    }

    func updateFavoriteMovies(movie: Movie, favorite: Bool){
        movieService.updateFavoriteMovies(movie: movie, favorite: favorite){ result in
            switch result {
                case .success(let isSuccess):
                    // update favorite in user defaults
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
                    self.outputFavoriteMovies?.didUpdateFavoriteMovies(isSuccess: isSuccess, isRemoved: !favorite)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputFavoriteMovies?.didFailToUpdateFavoriteMovies(error: error)
            }
        }
    }
}
