//
//  YWPortfolioView.swift
//  portfolio-manager-app
//
//  Created by Georgi Kamenov on 31.05.25.
//
import SwiftUI

struct YWPortfolioView: View {
    let portfolio: YWPortfolio
    
    var body: some View {
        List {
            Section(header: Text("Overview")) {
                Text(String(format: "Total Value: %.2f", portfolio.totalValue))
                Text(String(format: "Total Change: %+.2f%%", portfolio.growthPercentage))
                    .foregroundStyle(portfolio.growthPercentage > 0 ? .green : .red)
            }
            
            Section(header: Text("Assets")) {
                ForEach(portfolio.assets) { asset in
                    HStack
                    {
                        Text(String(format:"\(asset.ticker): %.2f", asset.value))
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(String(format:"%+.2f%%", asset.dailyChangePercentage))
                            Text(String(format:"%+.2f", asset.dailyChange))
                        }
                        .foregroundStyle(asset.dailyChange > 0 ? .green : .red)
                    }
                }
            }
        }
    }
}
