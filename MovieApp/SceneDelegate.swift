//
//  SceneDelegate.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScence = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: UIScreen.main.bounds)
        window = UIWindow(windowScene: windowScence)
        let movieService: MovieService = APIManager()
        let viewModel = MovieViewModel(movieService: movieService)
        let homeViewController = HomeViewController(viewModel: viewModel)
        homeViewController.title = "Movies"
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .clear
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

