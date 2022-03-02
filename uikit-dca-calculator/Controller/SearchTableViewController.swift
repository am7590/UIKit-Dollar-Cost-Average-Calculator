//
//  ViewController.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/2/22.
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        performSearch()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func performSearch() {
        apiService.fetchSymbolePublisher(ticker: "S&P500").sink { (completion) in
            // If success
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            
            }
        
        } receiveValue: { (searchResults) in
            // If error
            print(searchResults)
        }.store(in: &subscribers)

    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        return cell
    }

}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}
