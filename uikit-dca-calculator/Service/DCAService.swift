//
//  DCAService.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/6/22.
//

import Foundation

struct DCAService {
    
    func calculate(asset: Asset, initialInvestmentAmount: Double,
                   monthlyDollarCostAveragingAmount: Double,
                   initialDateOfInvestmentIndex: Int) -> DCAResult {
        
        let investmentAmount = getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount, monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        let latestSharePrice = getLatestSharePrice(asset: asset)
        
        let numberOfShares = getNumberOfShares(asset: asset, initialInvestmentAmount: initialInvestmentAmount, monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)

        let currentValue = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)
        
        let isProfitable = currentValue > investmentAmount
        
        let gain = currentValue - investmentAmount
        
        let yield = gain / investmentAmount
        
        let annualReturn = getAnnualReturn(currentValue: currentValue, investmentAmount: investmentAmount, initialInvestmentAmount: initialDateOfInvestmentIndex)
        
        return .init(currentValue: currentValue,
                     investmentAmount: investmentAmount,
                     gain: gain,
                     yield: yield,
                     annualReturn: annualReturn, isProfitable: isProfitable)
        
        
        
    }
    
    // Initial investment + monthly contributions
    private func getInvestmentAmount(initialInvestmentAmount: Double, monthlyDollarCostAveragingAmount: Double, initialDateOfInvestmentIndex: Int) -> Double {
        
        var totalAmount = Double()
        totalAmount += initialInvestmentAmount
        let dollarCostAveragingAmount = initialDateOfInvestmentIndex.doubleValue * monthlyDollarCostAveragingAmount
        totalAmount += dollarCostAveragingAmount
        return totalAmount
    }
    
    // CAGR (compound annual growth rate) = ((ending value / beginning value) ^ (1 / years)) - 1
    private func getAnnualReturn(currentValue: Double, investmentAmount: Double, initialInvestmentAmount: Int) -> Double {
        let rate = currentValue / investmentAmount
        let years = (initialInvestmentAmount.doubleValue + 1) / 12 // Starts at 0
        return pow(rate, (1 / years)) - 1
    }
    
    
    // numberOfShares (initial + DCA) * latest share price
    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    
    private func getLatestSharePrice(asset: Asset) -> Double {
        return asset.timeSeriesMonthlyAdjusted.getMonthInfo().first?.adjustedClose ?? 0
        
    }
    
    
    private func getNumberOfShares(asset: Asset, initialInvestmentAmount: Double,
                                   monthlyDollarCostAveragingAmount: Double,
                                   initialDateOfInvestmentIndex: Int) -> Double {
        
        var totalShares = Double()
        
        // When the user makes their initial investment
        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonthInfo()[initialDateOfInvestmentIndex].adjustedOpen
        
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        totalShares += initialInvestmentShares
        
        // DCA average for shares bought at this time
        asset.timeSeriesMonthlyAdjusted.getMonthInfo().prefix(initialDateOfInvestmentIndex).forEach{ (MonthInfo) in
            let dcaInvestmentShares = monthlyDollarCostAveragingAmount / MonthInfo.adjustedOpen
            totalShares += dcaInvestmentShares
        }
        return totalShares
    }
    
    
}


struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gain: Double
    let yield: Double
    let annualReturn: Double
    let isProfitable: Bool
}
