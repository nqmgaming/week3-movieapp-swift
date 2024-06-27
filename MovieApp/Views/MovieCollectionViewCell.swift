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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }


    private func configure() {
        contentView.addSubview(viewContainer)
        contentView.addSubview(movieImage)
        viewContainer.addSubview(movieTitle)
        viewContainer.addSubview(movieDateRelease)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        viewContainer.layer.cornerRadius = 10

        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        movieDateRelease.translatesAutoresizingMaskIntoConstraints = false

        viewContainer.anchor(top: topAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, paddingTop: 30, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)

        movieImage.anchor(top: topAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: nil, paddingTop: 0 , paddingBottom: -15, paddingLeft: 16, paddingRight: 0, width: 90, height: 0)

        movieTitle.anchor(top: viewContainer.topAnchor, bottom: nil, leading: viewContainer.leadingAnchor, trailing: nil, paddingTop: 10, paddingBottom: 0, paddingLeft: 126, paddingRight: 0, width: 0, height: 0)

        movieDateRelease.anchor(top: movieTitle.bottomAnchor, bottom: nil, leading: viewContainer.leadingAnchor, trailing: nil, paddingTop: 5, paddingBottom: 0, paddingLeft: 126, paddingRight: 0, width: 0, height: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(with movie: Movie, isWatchList: Bool = false) {

        if isWatchList {
            print("Movie \(String(describing: movie.title))")
        }

        self.movieTitle.text = movie.title
        self.movieDateRelease.text = movie.releaseDate
        self.backGroundPath = movie.posterPath
    }
}
