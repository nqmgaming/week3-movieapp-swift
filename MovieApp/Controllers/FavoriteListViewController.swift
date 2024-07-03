//
//  WatchListViewController.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 2/7/24.
//

import UIKit

class FavoriteListViewController: UIViewController, MovieUpdateFavoriteViewModelOutput {

    func didUpdateFavoriteMovies(isSuccess: Bool, isRemoved: Bool) {
        if isSuccess || isRemoved {
            // update favorite list
            viewModel.fetchTrendingMovies()
        }
    }

    func didFailToUpdateFavoriteMovies(error: any Error) {
        print("Failed to update favorite list: \(error.localizedDescription)")
    }

    let favoriteTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .background
        tableView.separatorInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "movieCell")
        return tableView
    }()

    var favoriteList: [Movie]
    private let viewModel: MovieViewModel

    init(favoriteList: [Movie], viewModel: MovieViewModel) {
        self.favoriteList = favoriteList
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Favorite"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()



        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.backgroundColor = .background


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(favoriteTableView)
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @objc func didTapFavoriteButton() {
        let favoriteListVC = FavoriteListViewController(favoriteList: favoriteList, viewModel: viewModel)
        navigationController?.pushViewController(favoriteListVC, animated: true)
    }

    func getFavoriteMovies() {
        // viewModel.fetchFavoriteMovies()
    }

    func getWatchListMovies() {
        // viewModel.fetchWatchListMovies()
    }

    func setupUI() {
        // setup UI
        NSLayoutConstraint.activate([
            favoriteTableView.topAnchor.constraint(equalTo: view.topAnchor),
            favoriteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoriteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoriteTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
}

// MARK: - Table View
extension FavoriteListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = favoriteList[indexPath.row]
        let movieDetailVC = DetailViewController(movie: movie, viewModel: viewModel)
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        let movie = favoriteList[indexPath.row]
        cell.configureCell(with: movie)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    // set margin bottom for last cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == favoriteList.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: -10, bottom: 20, right: 10)
        }
    }

    // swipe to delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // delete movie from favorite list
            self.viewModel.updateFavoriteMovies(movie: self.favoriteList[indexPath.row], favorite: false)
            self.favoriteList.remove(at: indexPath.row)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete movie from favorite list
            self.viewModel.updateFavoriteMovies(movie: self.favoriteList[indexPath.row], favorite: false)
            self.favoriteList.remove(at: indexPath.row)
        }
    }

}
