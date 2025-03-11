//
//  UIColor+Hex.swift
//  PG5602eksamenH24
//
//  Created by Annabelle Deichmann Raaberg on 07/12/2024.
//

import Foundation
import UIKit

extension UIColor {
    // Function to convert UIColor to Hex String
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Get the components of the color (RGBA)
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        // Convert the RGBA components to a hex string
        let hex = String(format: "#%02lX%02lX%02lX", lroundf(Float(red * 255)),
                         lroundf(Float(green * 255)),
                         lroundf(Float(blue * 255)))
        return hex
    }
}
