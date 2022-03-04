//
//  TimeSeriesMonthlyAdjusted.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/4/22.
//

import Foundation

struct TimeSeriesMonthlyAdjusted: Decodable {
    
    let metadata: Metadata
    let timeSeries: [String: OHLC]
}

struct Metadata: Decodable {
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OHLC: Decodable {
    let open: String
    let close: String
    let adjustedClose: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
    }
    
}
