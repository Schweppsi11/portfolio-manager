//
//  PortfolioModel.swift
//  PortfolioAnalyst
//
//  Created by Georgi Kamenov on 13.10.24.
//

import Foundation

struct Portfolio {
    var totalValue: Double
    {
        var value = 0.0
        for asset in assets {
            value += asset.value
        }
        return value
    }
    var name: String
    var growthPercentage: Double {
        var totalChange = 0.0
        for asset in assets {
            totalChange += asset.dailyChange
        }
        let totalValuePreChange = totalChange + totalValue
        return totalChange / totalValuePreChange * 100
    }
    var assets: [Asset]
}



