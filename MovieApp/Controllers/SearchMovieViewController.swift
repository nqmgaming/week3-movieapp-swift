//
//  SearchMovieViewController.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 8/7/24.
//

import UIKit
import RxSwift
import RxCocoa

class SearchMovieViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private let viewModel: MovieViewModel
    var favoriteList: [Movie] = []
    var favoriteMovieIDs: Set<Int> = []
    var watchListId: Set<Int> = []
    var watchList: [Movie] = []

    init(viewModel: MovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Search"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var searchTextField: PaddedTextField = {
        let textField = PaddedTextField()
        textField.placeholder = "Search movie"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var emptySearchView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)

        let label = UILabel()
        label.text = "Search for movies"
        label.textColor = .systemGray
        label.textAlignment = .center
        stackView.addArrangedSubview(label)

        return stackView
    }()

//    private lazy var searchButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Search", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.layer.cornerRadius = 10
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()

    private lazy var searchResultUICollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "movieCell")
        return collectionView
    }()


    private var page: Int = 1
    private var searchQuery: String = ""
    private var searchResult: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        // Do any additional setup after loading the view.
        setup()
        binViewModel()
        searchTextField.rx.controlEvent(.editingChanged)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.searchQuery = self.searchTextField.text ?? ""
                self.viewModel.searchMovies(query: self.searchQuery)
            })
            .disposed(by: disposeBag)

//        searchButton.rx.tap
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//                self.searchQuery = self.searchTextField.text ?? ""
//                self.viewModel.searchMovies(query: self.searchQuery)
//            })
//            .disposed(by: disposeBag)

    }

    private func showHideEmptySearchView(){
        if searchResult.isEmpty {
            emptySearchView.isHidden = false
            searchResultUICollectionView.isHidden = true
        } else {
            emptySearchView.isHidden = true
            searchResultUICollectionView.isHidden = false
        }
    }

    private func setup(){
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
//        view.addSubview(searchButton)
        view.addSubview(searchResultUICollectionView)
        view.addSubview(emptySearchView)

        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 10, paddingRight: -10, width: 0, height: 0)

        searchTextField.anchor(top: titleLabel.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 10, paddingRight: -10, width: 0, height: 40)

//        searchButton.anchor(top: searchTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 10, paddingRight: -10, width: 0, height: 40)

        searchResultUICollectionView.delegate = self
        searchResultUICollectionView.dataSource = self
        searchResultUICollectionView.anchor(top: searchTextField.bottomAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 10, paddingRight: -10, width: 0, height: 0)

        emptySearchView.anchor(top: searchTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 10, paddingRight: -10, width: 0, height: 0)

    }
    private func binViewModel(){
        // Search movies
        viewModel.searchMovies(query: "")
        viewModel.searchListMovie
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                print(movies)
                if self?.page == 1 {
                    self?.searchResult = movies.results ?? []
                } else {
                    self?.searchResult.append(contentsOf: movies.results ?? [])
                }
                self?.searchResultUICollectionView.reloadData()
                self?.showHideEmptySearchView()
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
//                self.showAlert(title: "Error", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // Fetch watchlist movies
        viewModel.fetchWatchListMovies()
        viewModel.watchListMovies
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.watchList = movies.results ?? []
                self?.searchResultUICollectionView.reloadData()
                self?.watchListId = Set(movies.results?.map { $0.id } ?? [])
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
//                self.showAlert(title: "Error", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // Fetch favorite movies
        viewModel.fetchFavoriteMovies()
        viewModel.favoriteMovies
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.favoriteList = movies.results ?? []
                self?.searchResultUICollectionView.reloadData()
                self?.favoriteMovieIDs = Set(movies.results?.map { $0.id } ?? [])
            })
            .disposed(by: disposeBag)

        viewModel.errors
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
//                self.showAlert(title: "Error", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}


extension SearchMovieViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // if searchList is not empty, show searchList

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard indexPath.row < searchResult.count else { return cell }

            let movie = searchResult[indexPath.row]
            let isWatchList = watchListId.contains(movie.id)
            cell.movieImage.heroID = "heroImage_\(movie.id)"
            cell.configureCell(with: movie, isWatchList: isWatchList)
            return cell

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResult.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.9, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let movie = searchResult[indexPath.row]
        let isWatchList = watchListId.contains(movie.id)
        let isFavorite = favoriteList.contains(where: { $0.id == movie.id })
        let movieDetailVC = DetailViewController(movie: movie, viewModel: viewModel, isWatchList: isWatchList, isFavorite: isFavorite)
        navigationController?.pushViewController(movieDetailVC, animated: true)

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
            viewModel.searchMovies(query: searchQuery, page: page)
        }
    }

    // pull to refresh
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }


}
