//
//  AppDelegate.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import UIKit
import Hero

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
            navigationController.hero.isEnabled = true
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }

        // Cache
        let memoryCapacity = 500 * 1024 * 1024 // 500 MB
        let diskCapacity = 500 * 1024 * 1024 // 500 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myCache")

        URLCache.shared = cache

        return true
    }
}

