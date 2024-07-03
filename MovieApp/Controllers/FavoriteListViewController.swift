//
//  WatchListViewController.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 2/7/24.
//

import UIKit

class FavoriteListViewController: UIViewController, MovieUpdateFavoriteViewModelOutput, MovieViewModelOutput {
    func didFetchMovies(movies: ListMovies) {

    }

    func didFetchWatchListMovies(movies: ListMovies) {

    }

    func didFetchFavoriteMovies(movies: ListMovies) {
        guard let movie = movies.results else { return }
        favoriteList.removeAll()
        favoriteList.append(contentsOf: movie)
        self.watchListId = Set(favoriteList.map { $0.id })
        DispatchQueue.main.async {
            self.favoriteTableView.reloadData()
        }
    }

    func didFailToFetchMovies(error: any Error) {
        print("Failed to fetch movies: \(error.localizedDescription)")
    }


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

    // refresh control
    private let refreshControl = UIRefreshControl()

    var favoriteList: [Movie]
    var watchListId: Set<Int>
    private let viewModel: MovieViewModel

    init(favoriteList: [Movie], viewModel: MovieViewModel, watchListId: Set<Int>) {
        self.favoriteList = favoriteList
        self.watchListId = watchListId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.outputFavoriteMovies = self
        viewModel.outputMovies = self
        viewModel.fetchTrendingMovies()
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


        setup()


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

    func getFavoriteMovies() {
        // viewModel.fetchFavoriteMovies()
    }

    func getWatchListMovies() {
        // viewModel.fetchWatchListMovies()
    }

    func setup(){
        // refresh control
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Movies ...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        favoriteTableView.refreshControl = refreshControl
    }
}

// MARK: - Table View
extension FavoriteListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = favoriteList[indexPath.row]
        let isWatchList = watchListId.contains(movie.id)
        let movieDetailVC = DetailViewController(movie: movie, viewModel: viewModel, isWatchList: isWatchList, isFavorite: true)
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
            DispatchQueue.main.async {
                self.favoriteList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete movie from favorite list
            self.viewModel.updateFavoriteMovies(movie: self.favoriteList[indexPath.row], favorite: false)
            DispatchQueue.main.async {
                self.favoriteList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    // pull to refresh
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            viewModel.fetchTrendingMovies()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            viewModel.fetchTrendingMovies()
        }
    }

}

// MARK: - Refresh
extension FavoriteListViewController {
    @objc func refresh() {
        viewModel.fetchTrendingMovies()
        refreshControl.endRefreshing()
    }
}
