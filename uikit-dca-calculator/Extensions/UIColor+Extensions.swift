//
//  UIColor+Extensions.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/13/22.
//

import UIKit

extension UIColor {
    
    
    
    static let redTheme = UIColor("fae2e1")
    static let greenTheme = UIColor("b0f1dd")
    
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if(cString.hasPrefix("#")) { cString.removeFirst() }
        
        if((cString.count) != 6) {
            self.init("ff0000")  // Wrong input = red color
            return
        }
        
        var rbgValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rbgValue)
        
        self.init(red: CGFloat((rbgValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rbgValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat((rbgValue & 0x0000FF) >> 16) / 255.0,
                  alpha: alpha)
        
        
    }
    
    
}
