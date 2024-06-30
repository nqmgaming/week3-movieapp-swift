//
//  MovieViewModelOutput.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

protocol MovieViewModelOutput: AnyObject {
    func didFetchMovies(movies: ListMovies)
    func didFetchWatchListMovies(movies: ListMovies)
    func didUpdateWatchListMovies(isSuccess: Bool)
    func didFailToFetchMovies(error: Error)
}

protocol MovieDetailViewModelOutput: AnyObject {
    func didFetchMovieDetail(movie: Movie)
    func didFailToFetchMovieDetail(error: Error)
}

