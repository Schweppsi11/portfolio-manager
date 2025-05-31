//
//  Asset.swift
//  PortfolioAnalyst
//
//  Created by Georgi Kamenov on 13.10.24.
//

import Foundation

class YWAsset:Identifiable {
    let id = UUID()
    var ticker: String //Ticker should always be unique
    var name: String
    var value: Double
    private var oldValue: Double?
    
    var dailyChange: Double {
        if let oldValue {
            return value - oldValue
        }
        self.oldValue = value
        return 0
    }
    
    var dailyChangePercentage: Double {
        if let oldValue = oldValue {
            return (value - oldValue) / oldValue * 100
        }
        return 0
    }
    
    init(ticker: String, name: String, value: Double, oldValue: Double? = nil) {
        self.ticker = ticker
        self.name = name
        self.value = value
        self.oldValue = oldValue
        
        Task {
            await fetchAssetInfo()
        }
    }
    
    func fetchAssetInfo() async -> [String:Any] {
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(ticker)&interval=5min&apikey=\(VantageAPIConstants.apiKey)"
        let request = URLRequest(url: URL(string: url)!)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let result = json as? [String:Any] else { return [:] }
            print(result)
            
            return result
        } catch {
            print(error)
            return [:]
        }
    }
}
