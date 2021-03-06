//
//  ViewController.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/2/22.
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimable {
    
    
    private enum Mode {
        case onboarding
        case search
    }
    

    // Make a search bar programatically
    // Boilerplate code to ensure the app compiles at all time
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or ticker symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?  // Is nil until a search
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }
     
    
    private func setupTableView() {
        tableView.isScrollEnabled = false  // Makes view not scrollable
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        
        // Call the API every 750 milliseconds
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                
                // Stops function from searching empty query (bug fix)
                guard !searchQuery.isEmpty else {return}
                
                // Loading animation
                showLoadingAnimation()
                
                
                self.apiService.fetchSymbolePublisher(ticker: searchQuery).sink { (completion) in
                    // If error
                    
                    // Hide animation upon callback
                    hideLoadingAnimation()

                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished: break
        
                    }
                    
                } receiveValue: { (searchResults) in
                    // If success
                    //print(searchResults)
                    self.searchResults = searchResults

                    // Reload tableview data
                    self.tableView.reloadData()
                    
                    self.tableView.isScrollEnabled = true  // Enable scrolling w/ results
                    
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
        
        // Observe mode
        $mode.sink { [unowned self] (mode) in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
                    
            case .search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchTableViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult)
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.item]
            let symbol = searchResult.symbol
            handleSelection(for: symbol, searchResult: searchResult)
        }
        
        // Prevent cells from being selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Called when the user types on the table view cell
    private func handleSelection(for symbol: String, searchResult: SearchResult) {
        
        // Loading animation
        showLoadingAnimation()
        
        // Fetch data
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(ticker: symbol).sink { (completionResult) in
            self.hideLoadingAnimation()
            switch completionResult {
            case .failure(let error):
                print(error)
            case .finished: break  // Unlikely to happen
            }
        
        } receiveValue: { (timeSeriesMonthlyAdjusted) in
            self.hideLoadingAnimation()
            let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
            self.performSegue(withIdentifier: "showCalculator", sender: asset)
//            print("success: \(timeSeriesMonthlyAdjusted.getMonthInfo())")
            self.searchController.searchBar.text = nil  // Gets rid of redundent api calls after navigating back from calculator view
            
            
        }.store(in: &subscribers)

        
        
        //performSegue(withIdentifier: "showCalculator", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalculator",
            let destination = segue.destination as? CalculatorTableViewController,
            let asset = sender as? Asset {
            destination.asset = asset
        }
    }

}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    // Responds to search queries; updates tableview with results
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else {
            // Display SearchPlaceholderView when the cancel button is pressed
            if !searchController.isActive {
                print("won't present")
                self.tableView.backgroundView = SearchPlaceholderView()
            }
            
            return
            
        }
        
        self.searchQuery = searchQuery
        
        // Make API call with query
        
    }

    
    // Triggers when the search bar is tapped
    func willPresentSearchController(_ searchController: UISearchController) {
        print("will present")
        mode = .search
    }

}
