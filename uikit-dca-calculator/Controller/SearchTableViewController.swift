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
        performSegue(withIdentifier: "showCalculator", sender: nil)
    }

}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    // Responds to search queries; updates tableview with results
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
        
        // Make API call with query
        
    }
    
    
    // Triggers when the search bar is tapped
    func willPresentSearchController(_ searchController: UISearchController) {
        print("will present")
        mode = .search
    }
    
    
}
