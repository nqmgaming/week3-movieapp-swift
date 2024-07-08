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
        self.hero.modalAnimationType = .selectBy(presenting:.push(direction: .down), dismissing: .fade)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        // create button on navigation bar to show favorite list
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(didTapFavoriteButton))
        favoriteButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = favoriteButton

        // create button search on left navigation bar
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = searchButton

        view.backgroundColor = .background
        showLoadingView()
        setupUI()
//        setupSearchController()
        layoutUI()
        bindViewModel()
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
        viewModel.fetchMovies(page: page)
        viewModel.movies
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.trendingMovies.append(contentsOf: movies.results ?? [])
                self?.collectionViewTrending.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.showAlert(title: "Error", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // Fetch watchlist movies
        viewModel.fetchWatchListMovies()
        viewModel.watchListMovies
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.watchList = movies.results ?? []
                self?.collectionViewTrending.reloadData()
                self?.watchlistMovieIDs = Set(movies.results?.map { $0.id } ?? [])
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.showAlert(title: "Error", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // Fetch favorite movies
        viewModel.fetchFavoriteMovies()
        viewModel.favoriteMovies
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.favoriteList = movies.results ?? []
                self?.collectionViewTrending.reloadData()
                self?.favoriteMovieIDs = Set(movies.results?.map { $0.id } ?? [])
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.showAlert(title: "Error", message: error.localizedDescription)
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
            refreshControl.endRefreshing()
            refresh()
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

    @objc func didTapSearchButton() {
        let searchViewController = SearchMovieViewController(viewModel: viewModel)
        searchViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchViewController, animated: true)

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

// MARK: - Alert
extension HomeViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
