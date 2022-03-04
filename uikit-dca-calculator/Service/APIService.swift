//
//  APIService.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/2/22.
//

import Foundation
import Combine

struct APIService {
    
    // Custom error
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    // Get a randome key on each call
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    // Select API key by random
    // These API keys are free but only handle a few requests per min
    let keys = ["CC57C4UA589EXWDK", "33490Y7WD4GBLC4Q", "GYH1VMWUNLRRHFCD"]
    
    
    // SearchResults is the success model, or Error if an error occurs
    // Fetch data for populating search table view data
    func fetchSymbolePublisher(ticker: String) -> AnyPublisher<SearchResults, Error> {
        
        guard let ticker = ticker.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher()}
        
        print(ticker)
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(ticker)&apikey=\(API_KEY)"
        
        
        
        guard let url = URL(string: urlString) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }
        
        print(url)
        
        // Return URLSession thats received on the main thread
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
    
//    func fetchTimeSeriesMonthlyAdjustedPublisher(ticker: String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error> {
//        
//        let result = parseQuery(text: ticker)
//        
//        var queryString = String()
//        
//        switch result {
//        case.success(let query):
//            queryString = query
//        default:
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//        
//        guard let ticker = ticker.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
//            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher()}
//        
//        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(ticker)&apikey=\(API_KEY)"
//
//        guard let url = URL(string: urlString) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }
//        
//        // Return URLSession thats received on the main thread
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .map({ $0.data })
//            .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
//            .receive(on: RunLoop.main)
//            .eraseToAnyPublisher()
//        
//    }
    
    
    private func parseQueryString(text: String) -> Result<String, Error> {
        
        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(query)
        } else {
            return .failure(APIServiceError.encoding)
        }
        
        
    }
    
    
}
