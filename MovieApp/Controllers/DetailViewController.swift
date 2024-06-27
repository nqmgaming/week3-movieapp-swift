//
//  DetailViewController.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 27/6/24.
//

import UIKit

class DetailViewController: UIViewController {


    let movie: Movie

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let textLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        print("Detail View Controller: \(movie)")

        view.backgroundColor = .cyan
        textLabel.text = "Detail View Controller"
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 24)
        textLabel.textColor = .black
        view.addSubview(textLabel)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }


}
