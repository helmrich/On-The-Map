//
//  ColorExtension.swift
//  On The Map
//
//  Created by Tobias Helmrich on 27.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension UIColor {
    static func darkenColor(originalRed: CGFloat, originalGreen: CGFloat, originalBlue: CGFloat, by amount: CGFloat) -> UIColor {
        
        func getNewColorValue(originalColorValue: CGFloat) -> CGFloat {
            if originalColorValue - amount < 0 {
                return 0
            } else {
                return originalColorValue - amount
            }
        }
        
        let newRed = getNewColorValue(originalColorValue: originalRed)
        let newGreen = getNewColorValue(originalColorValue: originalGreen)
        let newBlue = getNewColorValue(originalColorValue: originalBlue)
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1)
        
        
    }
    
    static func lightenColor(originalRed: CGFloat, originalGreen: CGFloat, originalBlue: CGFloat, by amount: CGFloat) -> UIColor {
        
        func getNewColorValue(originalColorValue: CGFloat) -> CGFloat {
            if originalColorValue + amount > 1 {
                return 1
            } else {
                return originalColorValue + amount
            }
        }
        
        let newRed = getNewColorValue(originalColorValue: originalRed)
        let newGreen = getNewColorValue(originalColorValue: originalGreen)
        let newBlue = getNewColorValue(originalColorValue: originalBlue)
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1)
        
        
    }
}
