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
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    
    
    
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
        
        // Stop text from appearing when the textfield is tapped
        initialDateOfInvestmentTextField.delegate = self
        
    } //showDateSelection
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Sends data to DateSelectionTableViewController
        if segue.identifier == "showDateSelection", let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController, let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
        }
    }
    
    
    private func handleDateSelection(at index: Int) {
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfo() {
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
}



extension CalculatorTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == initialDateOfInvestmentTextField {
            // Move to date selection view
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
        }
        
        return false  // True means the keyboard will show
    }
}
