//
//  LoginTextField.swift
//  On The Map
//
//  Created by Tobias Helmrich on 27.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    override func awakeFromNib() {
        layer.cornerRadius = 2
    }
    
    // Overriding this function in order to add a CGRect with a "padding" of 10 at the left side to the text field
    // so it's indented
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    // Adds the same "padding" of 10 to the text field when it's edited
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
}
