//
//  PaddedTextField.swift
//  MovieApp
//
//  Created by Nguyen Quang Minh on 8/7/24.
//

import UIKit

class PaddedTextField: UITextField {

    // Padding for text field content
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    // Override method for placeholder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    // Override method for text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    // Override method for editing text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
