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
                    self.outputMovies?.didFetchWatchListMovies(movies: movies)
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
                    print(isSuccess, isRemoved)
                    self.outputUpdateWatchListMovies?.didUpdateWatchListMovies(isSuccess: isSuccess, isRemoved: isRemoved)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputUpdateWatchListMovies?.didFailToUpdateWatchListMovies(error: error)
            }
        }
    }
}
