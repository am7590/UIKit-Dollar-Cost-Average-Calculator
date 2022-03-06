//
//  UITextField+Extensions.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/5/22.
//

import UIKit

extension UITextField {
    
    func addDoneButton() {
        
        // Add a toolbar
        let screenWidth = UIScreen.main.bounds.width
        let doneToolBar: UIToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        doneToolBar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // objc method is called each time button is tapped
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
       
        // Bar buttons items
        let items = [flexSpace, doneBarButtonItem]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        inputAccessoryView = doneToolBar
        
    }
    
    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }
    
    
}


