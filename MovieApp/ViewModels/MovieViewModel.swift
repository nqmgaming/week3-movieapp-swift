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

    init(movieService: MovieService) {
        self.movieService = movieService
    }

    func fetchTrendingMovies(){
        movieService.fetchPopularMovies { result in
            switch result {
                case .success(let movies):
                    self.outputMovies?.didFetchMovies(movies: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.outputMovies?.didFailToFetchMovies(error: error)
            }
        }
    }
}
