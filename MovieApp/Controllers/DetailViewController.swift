import UIKit
import Cosmos
import Kingfisher
import Hero
import RxSwift
import RxCocoa

class DetailViewController: UIViewController{

    private let disposeBag = DisposeBag()

    let movieId: Int
    var isWatchList: Bool = false
    var movie: Movie
    var movieVideo: Videos?
    var isFavorite: Bool = false
    private let viewModel: MovieViewModel

    init(movie: Movie, viewModel: MovieViewModel, isWatchList: Bool = false, isFavorite: Bool = false) {
        self.movieId = movie.id
        self.movie = movie
        self.isWatchList = isWatchList
        self.viewModel = viewModel
        self.isFavorite = isFavorite
        super.init(nibName: nil, bundle: nil)
        self.favoriteImageView.image = isFavorite ? heartFillImage : heartImage
        self.watchTrailerButton.addTarget(self, action: #selector(watchTrailerButtonTapped), for: .touchUpInside)
        self.watchListButton.addTarget(self, action: #selector(watchListButtonTapped), for: .touchUpInside)
        self.addToFavoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        // if screen large than content size, disable scroll
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


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

    private lazy var containerRatingAndFavoriteStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [containerRatingStackView, favoriteContainerView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()

    private lazy var containerRatingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ratingLabel, ratingView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
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
        view.rating = 0
        return view
    }()

    private lazy var favoriteContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var heartImage: UIImage = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        return UIImage(systemName: "heart", withConfiguration: config)!
    }()

    private lazy var heartFillImage: UIImage = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        return UIImage(systemName: "heart.fill", withConfiguration: config)!
    }()

    private lazy var favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .clbutton
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var addToFavoriteButton: UIButton = {
        let button = UIButton()
        return button
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
        // Set font size to 18
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()

    private lazy var watchListButton: UIButton = {
        let button = UIButton()
        button.setTitle("\(isWatchList ? "Remove from Watchlist" : "Add to Watchlist")", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.isUserInteractionEnabled = true
        // Set font size to 18
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
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
        hero.isEnabled = true
        self.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing:.fade)
        backdropImageView.hero.id = "heroImage_\(movie.id)"
        descriptionLabel.hero.isEnabled = true
        descriptionLabel.hero.modifiers = [.arc, .scale(0.8)]
        navigationController?.navigationBar.prefersLargeTitles = false
        showLoadingView()
        view.backgroundColor = .background
        setupScrollView()
        setup()
        layout()
        style()
        loadGenres()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.largeTitleDisplayMode = .never

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }

    private func bindViewModel(){
        viewModel.fetchMovieDetail(movieID: movieId)
        viewModel.movieDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movieDetail in
                self?.movie = movieDetail
                self?.ratingView.rating = self?.movie.getRatingStar() ?? 0
                self?.descriptionLabel.text = self?.movie.getDesc()
                self?.durationLabel.attributedText = self?.createDurationAttributedString()
                self?.genresLabel.attributedText = self?.createGenresAttributedString()

                self?.dismissLoadingView()
            }).disposed(by: disposeBag)

        viewModel.fetchMovieVideos(movieID: movieId)
        viewModel.movieVideos
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] videos in
                self?.movieVideo = videos
            }).disposed(by: disposeBag)
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -50),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    func setup() {
        contentView.addSubview(backdropImageView)
        contentView.addSubview(titleLable)
        contentView.addSubview(genreCollectionView)
        contentView.addSubview(containerRatingAndFavoriteStackView)
        favoriteContainerView.addSubview(favoriteImageView)
        favoriteContainerView.addSubview(addToFavoriteButton)
        contentView.addSubview(genresLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(releasedDateLabel)
        contentView.addSubview(containerButtonStackView)
        contentView.addSubview(descriptionLabel)
    }


    func layout() {
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3)
        ])

        titleLable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 10),
            titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        genreCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genreCollectionView.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 10),
            genreCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            genreCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            genreCollectionView.heightAnchor.constraint(equalToConstant: 30)
        ])

        containerRatingAndFavoriteStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerRatingAndFavoriteStackView.topAnchor.constraint(equalTo: genreCollectionView.bottomAnchor, constant: 20),
            containerRatingAndFavoriteStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerRatingAndFavoriteStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])

        favoriteContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteContainerView.widthAnchor.constraint(equalToConstant: 30),
            favoriteContainerView.heightAnchor.constraint(equalToConstant: 30)
        ])

        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteImageView.topAnchor.constraint(equalTo: favoriteContainerView.topAnchor),
            favoriteImageView.leadingAnchor.constraint(equalTo: favoriteContainerView.leadingAnchor),
            favoriteImageView.trailingAnchor.constraint(equalTo: favoriteContainerView.trailingAnchor),
            favoriteImageView.bottomAnchor.constraint(equalTo: favoriteContainerView.bottomAnchor),
            favoriteImageView.widthAnchor.constraint(equalTo: favoriteContainerView.widthAnchor),
            favoriteImageView.heightAnchor.constraint(equalTo: favoriteContainerView.heightAnchor)
        ])

        favoriteImageView.sendSubviewToBack(favoriteImageView)

        addToFavoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addToFavoriteButton.topAnchor.constraint(equalTo: favoriteContainerView.topAnchor),
            addToFavoriteButton.leadingAnchor.constraint(equalTo: favoriteContainerView.leadingAnchor),
            addToFavoriteButton.trailingAnchor.constraint(equalTo: favoriteContainerView.trailingAnchor),
            addToFavoriteButton.bottomAnchor.constraint(equalTo: favoriteContainerView.bottomAnchor)
        ])

        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genresLabel.topAnchor.constraint(equalTo: containerRatingAndFavoriteStackView.bottomAnchor, constant: 30),
            genresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 10),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        releasedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            releasedDateLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            releasedDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            releasedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        containerButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerButtonStackView.topAnchor.constraint(equalTo: releasedDateLabel.bottomAnchor, constant: 20),
            containerButtonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerButtonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerButtonStackView.heightAnchor.constraint(equalToConstant: 45)
        ])

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: containerButtonStackView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func style() {
        backdropImageView.loadImage(from: movie.backdropURL)
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
        // Open the trailer in YouTube app
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=\(movieVideo?.results.first?.key ?? "")")!
        UIApplication.shared.open(movieVideo?.getVideoURL() ?? youtubeURL, options: [:], completionHandler: nil)
    }

    @objc func watchListButtonTapped() {
        // Update watchlist
        viewModel.updateWatchListMovies(movie: movie, watchlist: !isWatchList, isRemoved: isWatchList)
        self.isWatchList = !self.isWatchList
        DispatchQueue.main.async {
            self.watchListButton.setTitle("\(self.isWatchList ? "Remove from Watchlist" : "Add to Watchlist")", for: .normal)
        }

    }

    @objc func didTapFavoriteButton() {
        // Update favorite
        self.isFavorite = !self.isFavorite
        viewModel.updateFavoriteMovies(movie: movie, favorite: isFavorite)
        DispatchQueue.main.async {
            self.favoriteImageView.image = self.isFavorite ? self.heartFillImage : self.heartImage
        }

    }
}

extension UIImageView {
    func loadImage(from url: URL?) {
        // check if url is nil
        if let url = url {
            let resource = KF.ImageResource(downloadURL: url)
            self.kf.setImage(with: resource)
        } else {
            self.image = UIImage(named: "placeholder")
        }

    }
}
