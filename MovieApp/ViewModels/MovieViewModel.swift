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

    init(movieService: MovieService) {
        self.movieService = movieService
    }

    func fetchTrendingMovies(){
        movieService.fetchTrendingMovies{ result in
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

   func getMovieDetail(movieID: Int){
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

    func updateWatchListMovies(movie: Movie){
        movieService.updateWatchListMovies(movie: movie){ result in
            switch result {
                case .success(let isSuccess):
                    self.outputMovies?.didUpdateWatchListMovies(isSuccess: isSuccess)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovies?.didFailToFetchMovies(error: error)
            }
        }
    }
}
