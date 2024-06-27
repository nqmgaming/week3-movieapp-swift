//
//  MovieService.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

protocol MovieService {
    func fetchPopularMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void)
}
