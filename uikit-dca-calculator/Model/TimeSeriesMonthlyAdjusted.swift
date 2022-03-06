//
//  TimeSeriesMonthlyAdjusted.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/4/22.
//

import Foundation


struct MonthInfo {
    let date: Date
    let adjustedOpen: Double
    let adjustedClose: Double
}

struct TimeSeriesMonthlyAdjusted: Decodable {
    
    let metadata: Metadata
    let timeSeries: [String: OHLC]
    
    enum CodingKeys: String, CodingKey {
        case metadata = "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }
    
    func getMonthInfo() -> [MonthInfo] {
        var monthInfoList: [MonthInfo] = []
        
        // Sort time series by date (key value)
        let sortedTimeSeries = timeSeries.sorted(by: {$0.key > $1.key})

        sortedTimeSeries.forEach { (dateString, ohlc) in
            // Read data format from JSON correctly
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dateString)!
            let adjustedOpen = getAdjustedOpen(ohlc: ohlc)
            let monthInfo = MonthInfo(date: date, adjustedOpen: adjustedOpen, adjustedClose: Double(ohlc.adjustedClose)!)
            monthInfoList.append(monthInfo)
        }
        
        return monthInfoList
    }
    
    // Adjusted open = open * (adjusted close / close)
    private func getAdjustedOpen(ohlc: OHLC) -> Double {
        return Double(ohlc.open)! * (Double(ohlc.adjustedClose)! / Double(ohlc.close)!)
    }
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
