//
//  CalculatorTableViewController.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/5/22.
//

import UIKit

class CalculatorTableViewController: UITableViewController {
    
    // Labels
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    
    // Text views
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    
    
    
    var asset: Asset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTextFields()
    }
    
    
    private func setupViews() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        
        // Currency label without ()
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        
        // Currency labels with ()
        currencyLabels.forEach { (label) in
            label.text = asset?.searchResult.currency.addBrackets()
            //label.text = asset?.searchResult.currency
            //label.text = "(" + asset!.searchResult.currency + ")"
        }
    }
    
    private func setupTextFields() {
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        
        
    }
}
