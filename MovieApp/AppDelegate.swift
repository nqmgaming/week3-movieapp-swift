//
//  AppDelegate.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds) // make a window with the size of the screen

        // Application have two view controllers: HomeViewController - show list movies, DetailViewController - show detail of a movie
        if let window = window {
            let movieService: MovieService = APIManager()
            let viewModel = MovieViewModel(movieService: movieService)
            let homeViewController = HomeViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: homeViewController)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }

        return true
    }
}

