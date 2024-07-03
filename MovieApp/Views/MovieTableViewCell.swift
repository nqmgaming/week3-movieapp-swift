import UIKit
import Kingfisher

class MovieTableViewCell: UITableViewCell {
    var posterPath: String? {
        didSet {
            if let posterPath = posterPath {
                let url = URL(string: Constants.BASE_IMAGE_URL + posterPath)
                movieImage.kf.setImage(with: url)
            }
        }
    }

    let containerView: UIView = {
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

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .systemBlue
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        label.textAlignment = .justified
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    var isWatchList: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ssss
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        contentView.addSubview(containerView)
        containerView.addSubview(movieImage)
        containerView.addSubview(movieTitle)
        containerView.addSubview(movieDateRelease)
        containerView.addSubview(descriptionLabel)


        containerView.translatesAutoresizingMaskIntoConstraints = false
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        movieDateRelease.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, paddingTop: 10, paddingBottom: -10, paddingLeft: 10, paddingRight: -10, width: 0, height: 0)

        movieImage.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, leading: containerView.leadingAnchor, trailing: nil, paddingTop: 0 , paddingBottom: 0, paddingLeft: 16, paddingRight: 0, width: 90, height: 0)

        movieTitle.anchor(top: containerView.topAnchor, bottom: nil, leading: movieImage.trailingAnchor, trailing: containerView.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 16, paddingRight: 16, width: 0, height: 0)

        movieDateRelease.anchor(top: movieTitle.bottomAnchor, bottom: nil, leading: movieImage.trailingAnchor, trailing: nil, paddingTop: 5, paddingBottom: 0, paddingLeft: 16, paddingRight: 0, width: 0, height: 0)

        descriptionLabel.anchor(top: movieDateRelease.bottomAnchor, bottom: nil, leading: movieImage.trailingAnchor, trailing: containerView.trailingAnchor, paddingTop: 15, paddingBottom: 0, paddingLeft: 16, paddingRight: 0, width: 0, height: 0)
    }

    func configureCell(with movie: Movie) {
        self.movieTitle.text = movie.title
        self.movieDateRelease.text = movie.getFormatDate()
        self.posterPath = movie.posterPath
        self.descriptionLabel.text = movie.overview
    }
}
