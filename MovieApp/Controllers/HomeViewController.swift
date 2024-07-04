import UIKit
import Hero
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    private let disposeBag = DisposeBag()

    let searchController = UISearchController(searchResultsController: nil)

    var trendingMovies: [Movie] = []
    var watchList: [Movie] = []
    var favoriteList: [Movie] = []
    var watchlistMovieIDs: Set<Int> = []
    var favoriteMovieIDs: Set<Int> = []
    var page = 1

    private let viewModel: MovieViewModel

    init(viewModel: MovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let collectionViewTrending: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    // refresh control
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemBlue
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true
        self.hero.modalAnimationType = .selectBy(presenting:.fade, dismissing: .fade)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        // create button on navigation bar to show favorite list
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(didTapFavoriteButton))
        favoriteButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = favoriteButton

        view.backgroundColor = .background
        showLoadingView()
        getWatchListMovies()
        getFavoriteMovies()
        setupUI()
        setupSearchController()
        layoutUI()
        bindViewModel()
        viewModel.fetchMovies(page: page)
        viewModel.fetchWatchListMovies()
        viewModel.fetchFavoriteMovies()
        dismissLoadingView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.largeTitleDisplayMode = .always
    }

    


    private func bindViewModel() {
        // Fetch trending movies
        viewModel.movies
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.trendingMovies.append(contentsOf: movies.results ?? [])
                self?.collectionViewTrending.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                // Xử lý lỗi ở đây
            })
            .disposed(by: disposeBag)

        // Fetch watchlist movies
        viewModel.watchListMovies
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.watchList = movies.results ?? []
                self?.watchlistMovieIDs = Set(movies.results?.map { $0.id } ?? [])
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                // Xử lý lỗi ở đây
            })
            .disposed(by: disposeBag)

        // Fetch favorite movies
        viewModel.favoriteMovies
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.favoriteList = movies.results ?? []
                self?.favoriteMovieIDs = Set(movies.results?.map { $0.id } ?? [])
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                // Xử lý lỗi ở đây
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup UI
extension HomeViewController {
    private func setupUI() {
        collectionViewTrending.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionViewTrending.dataSource = self
        collectionViewTrending.delegate = self

        // add refresh control to collection view
        collectionViewTrending.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        view.addSubview(collectionViewTrending)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([

            collectionViewTrending.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionViewTrending.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionViewTrending.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewTrending.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.tintColor = .blue
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.textColor = .black
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard indexPath.row < trendingMovies.count else { return cell }

        let movie = trendingMovies[indexPath.row]
        let isWatchList = watchlistMovieIDs.contains(movie.id)
        cell.movieImage.heroID = "heroImage_\(movie.id)"
        cell.movieTitle.heroID = "heroTitle_\(movie.id)"
        cell.movieDateRelease.heroID = "heroDate_\(movie.id)"
        cell.configureCell(with: movie, isWatchList: isWatchList)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trendingMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.9, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let movie = trendingMovies[indexPath.row]
        let isWatchList = watchlistMovieIDs.contains(movie.id)
        let isFavorite = favoriteMovieIDs.contains(movie.id)
        let detailViewController = DetailViewController(movie: movie, viewModel: viewModel, isWatchList: isWatchList, isFavorite: isFavorite)
        detailViewController.title = movie.title
        detailViewController.hidesBottomBarWhenPushed = true
        detailViewController.modalPresentationStyle = .popover
        navigationController?.pushViewController(detailViewController, animated: true)

    }



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 16, right: 16)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            page += 1
            viewModel.fetchMovies(page: page)
        }
    }

    // pull to refresh
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
            trendingMovies.removeAll()
            watchList.removeAll()
            favoriteList.removeAll()
            page = 1
            viewModel.fetchMovies(page: page)
            viewModel.fetchWatchListMovies()
            viewModel.fetchFavoriteMovies()
            refreshControl.endRefreshing()
        }
    }


}

// MARK: - NSUserDefault get watchlist movies
extension HomeViewController {
    func getWatchListMovies() {
        let watchListMovies = UserDefaults.standard.object(forKey: "watchlist") as? Data
        if let watchListMovies = watchListMovies {
            let decoder = JSONDecoder()
            if let decodedMovies = try? decoder.decode([Movie].self, from: watchListMovies) {
                watchList = decodedMovies
                watchlistMovieIDs = Set(watchList.map { $0.id })
            }
        }
    }

    func getFavoriteMovies() {
        let favoriteMovies = UserDefaults.standard.object(forKey: "favorite") as? Data
        if let favoriteMovies = favoriteMovies {
            let decoder = JSONDecoder()
            if let decodedMovies = try? decoder.decode([Movie].self, from: favoriteMovies) {
                favoriteList = decodedMovies
                favoriteMovieIDs = Set(favoriteList.map { $0.id })
            }
        }
    }

}

// Search bar
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.fetchMovies(page: page)
        } else {
//            viewModel.searchMovies(query: searchText)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.isEmpty {
            viewModel.fetchMovies(page: page)
        } else {
        }

    }

}

// MARK: - Actions
extension HomeViewController {
    @objc func didTapFavoriteButton() {
        let favoriteViewController = FavoriteListViewController(favoriteList: favoriteList, viewModel: viewModel, watchListId: watchlistMovieIDs)
        favoriteViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(favoriteViewController, animated: true)
    }

    @objc func refresh() {
        trendingMovies.removeAll()
        watchList.removeAll()
        favoriteList.removeAll()
        page = 1
        viewModel.fetchMovies(page: page)
        viewModel.fetchWatchListMovies()
        viewModel.fetchFavoriteMovies()
        refreshControl.endRefreshing()
    }
}

