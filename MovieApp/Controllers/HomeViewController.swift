import UIKit

class HomeViewController: UIViewController, MovieViewModelOutput, MovieUpdateWatchListViewModelOutput, MovieUpdateFavoriteViewModelOutput {
    func didUpdateFavoriteMovies(isSuccess: Bool, isRemoved: Bool) {

    }
    
    func didFailToUpdateFavoriteMovies(error: any Error) {
        
    }
    
    func didFetchFavoriteMovies(movies: ListMovies) {
        guard let movie = movies.results else { dismissLoadingView(); return }
        favoriteList.removeAll()
        favoriteList.append(contentsOf: movie)
        self.favoriteMovieIDs = Set(favoriteList.map { $0.id })
        DispatchQueue.main.async {
            self.collectionViewTrending.reloadData()
            self.dismissLoadingView()
        }
    }
    

    func didFailToUpdateWatchListMovies(error: any Error) {
        print("Failed to update watch list: \(error.localizedDescription)")
    }

    func didFetchWatchListMovies(movies: ListMovies) {
        guard let movie = movies.results else { dismissLoadingView(); return }
        watchList.removeAll()
        watchList.append(contentsOf: movie)
        self.watchlistMovieIDs = Set(watchList.map { $0.id })
        DispatchQueue.main.async {
            self.collectionViewTrending.reloadData()
            self.dismissLoadingView()
        }
    }

    func didUpdateWatchListMovies(isSuccess: Bool, isRemoved: Bool) {
        if isSuccess || isRemoved {
            //update watchlist
            viewModel.fetchTrendingMovies()
        }
    }

    func didFetchMovies(movies: ListMovies) {
        guard let movie = movies.results else { return }
        trendingMovies.append(contentsOf: movie)
        DispatchQueue.main.async {
            self.collectionViewTrending.reloadData()
            self.dismissLoadingView()
        }
    }

    func didFailToFetchMovies(error: any Error) {
        print("Failed to fetch movies: \(error.localizedDescription)")
    }

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
        self.viewModel.outputMovies = self
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
        viewModel.fetchTrendingMovies(page: page)
        setupUI()
        layoutUI()
        collectionViewTrending.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }


    // Removed the call from viewDidLayoutSubviews, it's better to keep it in one place
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // layoutUI() // not needed if called in viewDidLoad
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
        // check if the movie is in the watchlist
        let movie = trendingMovies[indexPath.row]
        let isWatchList = watchlistMovieIDs.contains(movie.id)
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
        let detailViewController = DetailViewController(movie: movie, viewModel: viewModel, isWatchList: isWatchList)
        detailViewController.title = movie.title
        detailViewController.hidesBottomBarWhenPushed = true
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
            viewModel.fetchTrendingMovies(page: page)
        }
    }

    // pull to refresh
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            page = 1
            viewModel.fetchTrendingMovies(page: page)
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

// MARK: - Actions
extension HomeViewController {
    @objc func didTapFavoriteButton() {
        let favoriteViewController = FavoriteListViewController(favoriteList: favoriteList, viewModel: viewModel)
        favoriteViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(favoriteViewController, animated: true)
    }

    @objc func refresh() {
        page = 1
        viewModel.fetchTrendingMovies(page: page)
    }
}
