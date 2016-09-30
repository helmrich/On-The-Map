//
//  ErrorLabel.swift
//  On The Map
//
//  Created by Tobias Helmrich on 28.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ErrorLabel: UILabel {
    // Overriding this function in order to give error labels insets at the left, right and top sides
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
