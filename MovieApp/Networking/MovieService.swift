//
//  MovieService.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

protocol MovieService {
    func fetchTrendingMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void)
    func fetchWatchListMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void)
    func fetchMovieDetail(movieID: Int, completion: @escaping (Swift.Result<Movie, Error>) -> Void)
    func fetchMovieVideos(movieID: Int, completion: @escaping (Swift.Result<Videos, Error>) -> Void)
    func updateWatchListMovies(movie: Movie, completion: @escaping (Swift.Result<Bool, Error>) -> Void)
}
