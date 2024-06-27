//
//  APIManager.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

class APIManager : MovieService {
    func fetchPopularMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void) {

        let headers = [
            "accept": "application/json"
        ]

        let url = URL(string: "\(Constants.BASE_URL)/trending/movie/week?api_key=\(Constants.API_KEY)")!
        print(url)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }

            guard response is HTTPURLResponse else {
                print("Invalid response")
                let unknowError = NSError(domain: "Unknow", code: 0, userInfo: nil)
                completion(.failure(unknowError))
                return
            }

            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    let listMovies = try decoder.decode(ListMovies.self, from: data)
                    completion(.success(listMovies))
                }else {
                    print("No data")
                    let parsingError = NSError(domain: "No data Error", code: 0)
                    completion(.failure(parsingError))
                }
            }catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }.resume() // why we need to call resume here? Because URLSession.shared.dataTask is a data task that returns data, and it is created in a suspended state. You need to call resume() to start the task.
    }

}
