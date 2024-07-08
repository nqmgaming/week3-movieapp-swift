//
//  WatchListViewController.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 2/7/24.
//

import UIKit
import Hero
import RxSwift
import RxCocoa

class FavoriteListViewController: UIViewController{

    private let disposeBag = DisposeBag()

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

    private let emptyView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "heart.slash.fill"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)

        let label = UILabel()
        label.text = "No favorite movies"
        label.textColor = .systemGray
        label.textAlignment = .center
        stackView.addArrangedSubview(label)

        return stackView
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
        title = "Favorite"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true
        hero.modalAnimationType = .selectBy(presenting: .fade, dismissing:.fade)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.backgroundColor = .background
        updateEmptyView()
        setup()

        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(favoriteTableView)
        view.addSubview(emptyView)

        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.frame = view.bounds

        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateEmptyView() {
        emptyView.isHidden = !favoriteList.isEmpty
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    private func bindViewModel(){
        viewModel.fetchFavoriteMovies()
        viewModel.favoriteMovies
            .subscribe(onNext: { [weak self] movies in
                self?.favoriteList = movies.results ?? []
                self?.favoriteTableView.reloadData()
                self?.updateEmptyView()
            })
            .disposed(by: disposeBag)
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
        cell.movieImage.hero.id = "heroImage_\(movie.id)"
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
                if self.favoriteList.isEmpty {
                    self.updateEmptyView()
                }
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
                self.updateEmptyView()
            }
        }
    }
    // pull to refresh
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            viewModel.fetchFavoriteMovies()
            viewModel.favoriteMovies
                .subscribe(onNext: { [weak self] movies in
                    self?.favoriteList = movies.results ?? []
                    self?.favoriteTableView.reloadData()
                })
                .disposed(by: disposeBag)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            // fetch more data
            viewModel.fetchFavoriteMovies()
            viewModel.favoriteMovies
                .subscribe(onNext: { [weak self] movies in
                    self?.favoriteList = movies.results ?? []
                    self?.favoriteTableView.reloadData()
                    self?.updateEmptyView()
                })
                .disposed(by: disposeBag)
        }
    }

}

// MARK: - Refresh
extension FavoriteListViewController {
    @objc func refresh() {
        refreshControl.endRefreshing()
        viewModel.fetchFavoriteMovies()
        viewModel.favoriteMovies
            .subscribe(onNext: { [weak self] movies in
                self?.favoriteList = movies.results ?? []
                self?.favoriteTableView.reloadData()
                self?.updateEmptyView()
            })
            .disposed(by: disposeBag)
    }
}
