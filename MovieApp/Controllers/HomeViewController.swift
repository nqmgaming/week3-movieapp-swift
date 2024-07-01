import UIKit

class HomeViewController: UIViewController, MovieViewModelOutput, MovieUpdateWatchListViewModelOutput {
    
    func didFailToUpdateWatchListMovies(error: any Error) {
        print("Failed to update watch list: \(error.localizedDescription)")
    }

    func didFetchWatchListMovies(movies: ListMovies) {
        guard let movie = movies.results else { dismissLoadingView(); return }
        watchList.removeAll() 
        watchList.append(contentsOf: movie)
        self.watchlistMovieIDs = Set(watchList.map { $0.id })
        print("Watchlist: \(watchList.count)")
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
    var watchlistMovieIDs: Set<Int> = []
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

    private let movieLabel: UILabel = {
        let label = UILabel()
        label.text = "Movies"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let collectionViewTrending: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        showLoadingView()
        getWatchListMovies()
        viewModel.fetchTrendingMovies(page: page)
        setupUI()
        layoutUI()
        collectionViewTrending.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

        view.addSubview(movieLabel)
        view.addSubview(collectionViewTrending)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            movieLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            movieLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            collectionViewTrending.topAnchor.constraint(equalTo: movieLabel.bottomAnchor, constant: 20),
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
}
