//
//  CalculatorTableViewController.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/5/22.
//

import UIKit
import Combine

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
        
    // Slider
    @IBOutlet weak var dateSlider: UISlider!
    
    // Results from calculation labels
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    
    
    
    
    var asset: Asset?
    
    @Published private var initialDateOfInvestmentIndex: Int?  // Perform an action when this var changes
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyDollarCostAveragingAmount: Int?
    
    private var subscribers = Set<AnyCancellable>()
    private let dcaService = DCAService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTextFields()
        setupDateSlider()
        observeForm()
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
        
    }
    
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfo().count {
            let dateSliderCount = count - 1
            dateSlider.maximumValue = dateSliderCount.floatValue
        }
    }
    
    
    private func observeForm() {
        $initialDateOfInvestmentIndex.sink { [weak self] (index) in
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            
            // Let slider dictate date values
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfo()[index].date.MMYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
            
            
        }.store(in: &subscribers)
        
        // This closure observes the event each time the user types
        // Listens to initialInvestmentAmountTextField
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            // Perform action when value changes
            self?.initialInvestmentAmount = Int(text) ?? 0
            // print(text)
        }.store(in: &subscribers)
        
        
        // Listens to monthlyDollarCostAveragingTextField
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            // Perform action when value changes
            self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0
            // print(text)
        }.store(in: &subscribers)
        
        // Update whenever any of the published vars change value
        Publishers.CombineLatest3($initialInvestmentAmount, $monthlyDollarCostAveragingAmount, $initialDateOfInvestmentIndex).sink { [weak self] (initialInvestmentAmount, monthlyDollarCostAveragingAmount, initialDateOfInvestmentIndex)  in
            
            // Do DCA calculations
            guard let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollarCostAveragingAmount = monthlyDollarCostAveragingAmount,
                  let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex,
                  let asset = self?.asset
            else { return }

            
            
            let result = self?.dcaService.calculate(asset: asset, initialInvestmentAmount: initialInvestmentAmount.doubleValue, monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount.doubleValue, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
            
            
            //print("\(initialInvestmentAmount), \(monthlyDollarCostAveragingAmount), \(initialDateOfInvestmentIndex),")
            self?.currentValueLabel.backgroundColor = (result?.isProfitable == true) ? .greenTheme : .redTheme
            self?.currentValueLabel.text = result?.currentValue.currencyFormat
            self?.investmentAmountLabel.text = result?.investmentAmount.currencyFormat
            self?.gainLabel.text = result?.gain.stringValue
            self?.yieldLabel.text = result?.yield.stringValue
            self?.annualReturnLabel.text = result?.annualReturn.stringValue
            
        }.store(in: &subscribers)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Sends data to DateSelectionTableViewController
        if segue.identifier == "showDateSelection", let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController, let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.selectedIndex = initialDateOfInvestmentIndex
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
        }
    }
    
    
    private func handleDateSelection(at index: Int) {
        // Return back to calculator view when a date cell is tapped
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        
        // Select cell
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfo() {
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
    }
    
    
}



extension CalculatorTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == initialDateOfInvestmentTextField {
            // Move to date selection view
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return false  // True means the keyboard will show
        }
        
        return true
    }
}
