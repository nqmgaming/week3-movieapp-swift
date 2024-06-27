import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    var backGroundPath: String? {
        didSet {
            guard let backgroundPath = backGroundPath else { return }

            if let imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(backgroundPath)") {
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }

                    if let data = data {
                        DispatchQueue.main.async {
                            self.movieImage.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }
    }

    let movieImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        return image
    }()

    let movieTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    let movieDateRelease: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    private func configure() {
        contentView.addSubview(movieImage)
        contentView.addSubview(movieTitle)
        contentView.addSubview(movieDateRelease)

        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        movieDateRelease.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            movieImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            movieImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),

            movieTitle.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: 5),
            movieTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            movieDateRelease.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: 5),
            movieDateRelease.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieDateRelease.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(with movie: Movie) {
        self.movieTitle.text = movie.title
        self.movieDateRelease.text = movie.releaseDate
        self.backGroundPath = movie.backdropPath
    }
}
