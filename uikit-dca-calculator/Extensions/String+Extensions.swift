//
//  String+Extensions.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/5/22.
//

import Foundation

extension String {
    
    func addBrackets() -> String {
        return "(\(self))"
    }
    
    func prefix(withText text: String) -> String {
        return text + self
    }
    
    
}
