//
//  MovieViewModelOutput.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

protocol MovieViewModelOutput: AnyObject {
    func didFetchMovies(movies: ListMovies)
    func didFailToFetchMovies(error: Error)
}
