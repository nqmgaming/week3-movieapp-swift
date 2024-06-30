import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    var posterPath: String? {
        didSet {
            guard let posterPath = posterPath else { return }

            if let imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
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

    let viewContainer: UIView = {

        let view = UIView()
        view.backgroundColor = .ssss
        return view

    }()

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
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()

    let movieDateRelease: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()

    let watchListLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var isWatchList: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }


    private func configure() {
        contentView.addSubview(viewContainer)
        contentView.addSubview(movieImage)
        viewContainer.addSubview(movieTitle)
        viewContainer.addSubview(movieDateRelease)
        viewContainer.addSubview(watchListLabel)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        viewContainer.layer.cornerRadius = 10

        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        movieDateRelease.translatesAutoresizingMaskIntoConstraints = false
        watchListLabel.translatesAutoresizingMaskIntoConstraints = false

        viewContainer.anchor(top: topAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, paddingTop: 30, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)

        movieImage.anchor(top: topAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: nil, paddingTop: 0 , paddingBottom: -15, paddingLeft: 16, paddingRight: 0, width: 90, height: 0)

        movieTitle.anchor(top: viewContainer.topAnchor, bottom: nil, leading: viewContainer.leadingAnchor, trailing: viewContainer.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 126, paddingRight: 0, width: 0, height: 0)

        movieDateRelease.anchor(top: movieTitle.bottomAnchor, bottom: nil, leading: viewContainer.leadingAnchor, trailing: nil, paddingTop: 5, paddingBottom: 0, paddingLeft: 126, paddingRight: 0, width: 0, height: 0)

        watchListLabel.anchor(top: movieDateRelease.bottomAnchor, bottom: nil, leading: viewContainer.leadingAnchor, trailing: nil, paddingTop: 15, paddingBottom: 0, paddingLeft: 126, paddingRight: 0, width: 0, height: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(with movie: Movie, isWatchList: Bool = false) {

        if isWatchList {
            self.isWatchList = true
            self.watchListLabel.text = "On my watchlist"
        }else {
            self.isWatchList = false
            self.watchListLabel.text = ""
        }
        self.movieTitle.text = movie.title
        self.movieDateRelease.text = movie.getFormatDate()
        self.posterPath = movie.posterPath
    }
}
