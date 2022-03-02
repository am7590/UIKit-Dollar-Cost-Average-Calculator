//
//  APIService.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/2/22.
//

import Foundation
import Combine

struct APIService {
    
    // Get a randome key on each call
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    // Select API key by random
    // These API keys are free but only handle a few requests per min
    let keys = ["CC57C4UA589EXWDK", "33490Y7WD4GBLC4Q", "GYH1VMWUNLRRHFCD"]
    
    
    // SearchResults is the success model, or Error if an error occurs
    func fetchSymbolePublisher(ticker: String) -> AnyPublisher<SearchResults, Error> {
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(ticker)&apikey=\(API_KEY)"
        let url = URL(string: urlString)!
        
        // Return URLSession thats received on the main thread
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
