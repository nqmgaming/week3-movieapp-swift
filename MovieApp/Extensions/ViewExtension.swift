//
//  UIViewController+Exxt.swift
//  GithubFlowers
//
//  Created by Nguyen Quang Minh on 20/6/24.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {

    func showLoadingView(){
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)

        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0

        UIView.animate(withDuration: 0.25, animations: {
            containerView.alpha = 0.3
        })

        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        activityIndicator.startAnimating()
    }

    func dismissLoadingView(){
        DispatchQueue.main.async {
            if let safeContainerView = containerView {
                safeContainerView.removeFromSuperview()
                containerView = nil
            }
        }
    }
}
