//
//  APIManager.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import Foundation

class APIManager : MovieService {
    func fetchTrendingMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void) {

        let headers = [
            "accept": "application/json"
        ]

        let url = URL(string: "\(Constants.BASE_URL)/trending/movie/week?api_key=\(Constants.API_KEY)")!

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

    func fetchWatchListMovies(completion: @escaping (Swift.Result<ListMovies, Error>) -> Void) {
        let headers = [
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ZGFmMGU2ZGRlYzc3MmYwOWU3YWU0NTkyZmQzNTQ0OSIsIm5iZiI6MTcxOTQ1OTUyNy43MzQwOSwic3ViIjoiNjYzM2M0MDNhMWM1OWQwMTIzZTZmMDgxIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.LsSjoWR-pClX4p8KCKZ8AxC2wfZXFElCmzkAZan1MJI"
        ]

        let url = URL(string: "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/watchlist/movies")!
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
        }.resume()
    }

    func updateWatchListMovies(movie: Movie, completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers = [
            "accept": "application/json",
            "content-type": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ZGFmMGU2ZGRlYzc3MmYwOWU3YWU0NTkyZmQzNTQ0OSIsIm5iZiI6MTcxOTQ1OTUyNy43MzQwOSwic3ViIjoiNjYzM2M0MDNhMWM1OWQwMTIzZTZmMDgxIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.LsSjoWR-pClX4p8KCKZ8AxC2wfZXFElCmzkAZan1MJI"
        ]

        guard let url = URL(string: "\(Constants.BASE_URL)/account/\(Constants.USER_ID)/watchlist") else {
            let urlError = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(urlError))
            return
        }

        print(url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        let body: [String: Any] = [
            "media_type": "movie",
            "media_id": movie.id,
            "watchlist": true
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                let unknownError = NSError(domain: "Unknown", code: 0, userInfo: nil)
                completion(.failure(unknownError))
                return
            }

            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(UpdateWatchListResponse.self, from: data)
                    completion(.success(result.success))
                } else {
                    print("No data")
                    let parsingError = NSError(domain: "No data Error", code: 0, userInfo: nil)
                    completion(.failure(parsingError))
                }
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }

}
