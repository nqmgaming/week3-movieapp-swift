import UIKit

class HomeViewController: UIViewController, MovieViewModelOutput {
    func didFetchMovies(movies: ListMovies) {
        guard let movie = movies.results else { return }
        trendingMovies = movie
        DispatchQueue.main.async {
            self.collectionViewTrending.reloadData()
        }
    }

    func didFailToFetchMovies(error: any Error) {
        print("Failed to fetch movies: \(error.localizedDescription)")
    }

    var trendingMovies: [Movie] = []

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
        viewModel.fetchTrendingMovies()
        setupUI()
        layoutUI()
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
            collectionViewTrending.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionViewTrending.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionViewTrending.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        let movie = trendingMovies[indexPath.row]
        cell.configureCell(with: movie)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trendingMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select item at index: \(indexPath.row)")
        navigationController?.pushViewController(DetailViewController(movie: trendingMovies[indexPath.row]), animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
