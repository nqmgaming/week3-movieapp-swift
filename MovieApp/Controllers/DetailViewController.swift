import UIKit
import TinyConstraints
import Cosmos

class DetailViewController: UIViewController, MovieDetailViewModelOutput {
    func didFetchMovieDetail(movie: Movie) {
        self.movie = movie
        DispatchQueue.main.async {
            self.titleLable.attributedText = self.createTitleAndDateAttributedString()
            self.ratingLabel.attributedText = self.createRatingAttributedString()
            self.genresLabel.attributedText = self.createGenresAttributedString()
            self.durationLabel.attributedText = self.createDurationAttributedString()
            self.descriptionLabel.text = movie.getDesc()
            self.genreCollectionView.reloadData()
        }
    }

    func didFailToFetchMovieDetail(error: any Error) {
        print("Failed to fetch movie detail: \(error.localizedDescription)")
    }


    let movieId: Int
    var movie: Movie
    private let viewModel: MovieViewModel

    init(movie: Movie, viewModel: MovieViewModel) {
        self.movieId = movie.id
        self.movie = movie
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.outputMovieDetail = self
        self.watchTrailerButton.addTarget(self, action: #selector(watchTrailerButtonTapped), for: .touchUpInside)
        self.watchListButton.addTarget(self, action: #selector(watchListButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLable : UILabel = {
        let label = UILabel()
        label.attributedText = createTitleAndDateAttributedString()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private func createTitleAndDateAttributedString() -> NSAttributedString {
        let fullText = "\(movie.getTitle())    (\(movie.getReleaseDate()))"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Define attributes for the entire text
        let fullRange = NSRange(location: 0, length: fullText.count)
        let fullAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        attributedString.addAttributes(fullAttributes, range: fullRange)

        // Define attributes for the date part
        if let range = fullText.range(of: "(\(movie.getReleaseDate()))") {
            let nsRange = NSRange(range, in: fullText)
            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.white
            ]
            attributedString.addAttributes(smallAttributes, range: nsRange)
        }

        return attributedString
    }

    private lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.frame.size.height = 30
        collectionView.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: GenreCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.attributedText = createRatingAttributedString()
        label.textAlignment = .left
        return label
    }()

    private func createRatingAttributedString() -> NSAttributedString {
        let fullText = "Rating: \(movie.getVoteAverage())/10"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Define attributes for the entire text
        let fullRange = NSRange(location: 0, length: fullText.count)
        let fullAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.white
        ]
        attributedString.addAttributes(fullAttributes, range: fullRange)

        // Define attributes for the "10" part
        if let range = fullText.range(of: "/10") {
            let nsRange = NSRange(range, in: fullText)
            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            attributedString.addAttributes(smallAttributes, range: nsRange)
        }

        return attributedString
    }

    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .precise
        view.settings.filledColor = .systemYellow
        view.settings.emptyBorderColor = .systemYellow
        view.settings.filledBorderColor = .systemYellow
        view.settings.starSize = 20
        view.settings.starMargin = 5
        view.settings.updateOnTouch = false
        view.rating = 4.1
        return view
    }()

    private lazy var genresLabel: UILabel = {
        let label = UILabel()
        label.attributedText = createGenresAttributedString()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private func createGenresAttributedString() -> NSAttributedString {
        let fullText = "Genres: \(genres.joined(separator: ", "))"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Define attributes for the entire text
        let fullRange = NSRange(location: 0, length: fullText.count)
        let fullAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.white
        ]
        attributedString.addAttributes(fullAttributes, range: fullRange)

        // Define attributes for the "Genres: " part
        if let range = fullText.range(of: "Genres: ") {
            let nsRange = NSRange(range, in: fullText)
            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            attributedString.addAttributes(smallAttributes, range: nsRange)
        }

        return attributedString
    }

    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.attributedText = createDurationAttributedString()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private func createDurationAttributedString() -> NSAttributedString {
        let fullText = "Duration: \(movie.getRuntime())"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Define attributes for the entire text
        let fullRange = NSRange(location: 0, length: fullText.count)
        let fullAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.white
        ]
        attributedString.addAttributes(fullAttributes, range: fullRange)

        // Define attributes for the "Duration: " part
        if let range = fullText.range(of: "Duration: ") {
            let nsRange = NSRange(range, in: fullText)
            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            attributedString.addAttributes(smallAttributes, range: nsRange)
        }

        return attributedString
    }

    private lazy var releasedDateLabel: UILabel = {
        let label = UILabel()
        label.attributedText = createReleasedDateAttributedString()
        return label
    }()

    private func createReleasedDateAttributedString() -> NSAttributedString {
        let fullText = "Released dated: \(movie.getFormatDate())"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Define attributes for the entire text
        let fullRange = NSRange(location: 0, length: fullText.count)
        let fullAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.white
        ]
        attributedString.addAttributes(fullAttributes, range: fullRange)

        // Define attributes for the "Released Date: " part
        if let range = fullText.range(of: "Released dated: ") {
            let nsRange = NSRange(range, in: fullText)
            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            attributedString.addAttributes(smallAttributes, range: nsRange)
        }

        return attributedString
    }

    private lazy var containerButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [watchTrailerButton, watchListButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private lazy var watchTrailerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Watch Trailer", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clbutton
        button.layer.cornerRadius = 22
        button.isUserInteractionEnabled = true
        return button
    }()

    private lazy var watchListButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add to Watchlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.isUserInteractionEnabled = true
        return button
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .justified
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()


    private var genres: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setup()
        layout()
        style()
        loadGenres()
        viewModel.getMovieDetail(movieID: movieId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    func setup() {
        view.addSubview(backdropImageView)
        view.addSubview(titleLable)
        view.addSubview(genreCollectionView)
        view.addSubview(ratingLabel)
        view.addSubview(ratingView)
        view.addSubview(genresLabel)
        view.addSubview(durationLabel)
        view.addSubview(releasedDateLabel)
        view.addSubview(containerButtonStackView)
        view.addSubview(descriptionLabel)
    }


    func layout() {
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backdropImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 200)
        ])

        titleLable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 10),
            titleLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        genreCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genreCollectionView.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 10),
            genreCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            genreCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            genreCollectionView.heightAnchor.constraint(equalToConstant: 30)
        ])

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: genreCollectionView.bottomAnchor, constant: 20),
            ratingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        ratingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            ratingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            ratingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genresLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 20),
            genresLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            genresLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 10),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        releasedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            releasedDateLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            releasedDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            releasedDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        containerButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerButtonStackView.topAnchor.constraint(equalTo: releasedDateLabel.bottomAnchor, constant: 20),
            containerButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            containerButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            containerButtonStackView.heightAnchor.constraint(equalToConstant: 45)
        ])

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: containerButtonStackView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    func style() {
        backdropImageView.loadImage(from: movie.backdropPath)
    }

    func loadGenres() {
        self.genres = ["Action", "Adventure", "Fantasy"]
        genreCollectionView.reloadData()
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.reuseIdentifier, for: indexPath) as! GenreCollectionViewCell
        cell.configure(with: genres[indexPath.item])
        return cell
    }

    // auto wrap the genre text
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = genres[indexPath.item]
        let width = text.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)]).width + 20
        return CGSize(width: width, height: 30)
    }
}

// MARK: - Actions
extension DetailViewController {
    @objc func watchTrailerButtonTapped() {
        print("Watch trailer button tapped")

        //Get link and open in safari
//        if let url = URL(string: self.movie.get) {
//            UIApplication.shared.open(url)
//        }

    }

    @objc func watchListButtonTapped() {
        print("Watchlist button tapped")
    }
}

extension UIImageView {
    func loadImage(from url: String?) {
        guard let urlString = url, let url = URL(string: "https://image.tmdb.org/t/p/w500\(urlString)") else {
            print("Invalid URL")
            self.image = UIImage(named: "placeholder") // Placeholder image
            return
        }

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.center
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    self.image = UIImage(named: "placeholder") // Placeholder image
                    return
                }

                guard let data = data else {
                    print("No data found")
                    self.image = UIImage(named: "placeholder") // Placeholder image
                    return
                }

                guard let image = UIImage(data: data) else {
                    print("Unable to create image")
                    self.image = UIImage(named: "placeholder") // Placeholder image
                    return
                }

                self.image = image

            }
        }
        task.resume()
    }
}

