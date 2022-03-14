//
//  Double+Extensions.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/6/22.
//

import Foundation

extension Double {
    
    var stringValue: String {
        return String(describing: self)
    }
    
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
    
    var percentageFormat: String {
        let formatter = NumberFormatter()
         formatter.numberStyle = .percent     // set to %
         formatter.maximumFractionDigits = 2  // 2 decimal points
         return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
    
    var currencyFormat: String {
       let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
    
    func toCurrencyFormat(hasDollarSymbol: Bool, hasDecimalPlaces: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if hasDollarSymbol == false {
            formatter.currencySymbol = ""
        }
        if hasDecimalPlaces == false {
            formatter.maximumFractionDigits = 0
        }
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
}
