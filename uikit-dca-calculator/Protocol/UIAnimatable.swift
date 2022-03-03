//
//  UIAnimatable.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/3/22.
//

import Foundation
import MBProgressHUD

protocol UIAnimable: UIViewController {
    func showLoadingAnimation()
    func hideLoadingAnimation()
}


extension UIAnimable {
    func showLoadingAnimation() {
        DispatchQueue.main.async {  // Run on main thread
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
    }
    
    func hideLoadingAnimation() {
        DispatchQueue.main.async {  // Run on main thread
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
}
