//
//  Date+Extensions.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/6/22.
//

import Foundation

extension Date {
    
    var MMYYFormat : String {
        let dateFormatter = DateFormatter()
        
        // Go to nsdateformatter.com to see all formats
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
}
