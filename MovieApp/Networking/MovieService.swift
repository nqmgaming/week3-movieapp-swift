//
//  MovieService.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation
import RxSwift

protocol MovieService {
    func fetchTrendingMovies(page: Int) -> Single<ListMovies>
    func fetchWatchListMovies() -> Single<ListMovies>
    func fetchFavoriteMovies() -> Single<ListMovies>
    func fetchMovieDetail(movieID: Int) -> Single<Movie>
    func fetchMovieVideos(movieID: Int) -> Single<Videos>
    func updateWatchListMovies(movie: Movie, watchlist: Bool) -> Single<Bool>
    func updateFavoriteMovies(movie: Movie, favorite: Bool) -> Single<Bool>
}
