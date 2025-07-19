//
//  CurrencyList.swift
//  InvoiceMaker
//
//  Created by Eze Chidera Paschal on 03/09/2024.
//
import SwiftUI

struct CurrencyInfo: Hashable {
    let code: String
    let symbol: String
    let name: String
    let rateUSD: Double
    let rateBDT: Double
}


func getCryptoCurrencies() -> [CurrencyInfo] {
    return [
        CurrencyInfo(code: "BTC", symbol: "₿", name: "Bitcoin", rateUSD: 67000, rateBDT: 7800000),
        CurrencyInfo(code: "ETH", symbol: "Ξ", name: "Ethereum", rateUSD: 3800, rateBDT: 440000),
        CurrencyInfo(code: "SOL", symbol: "◎", name: "Solana", rateUSD: 170, rateBDT: 20000),
        CurrencyInfo(code: "XRP", symbol: "✕", name: "XRP", rateUSD: 0.65, rateBDT: 75),
        CurrencyInfo(code: "DOGE", symbol: "Ð", name: "Dogecoin", rateUSD: 0.14, rateBDT: 16)
    ]
}


struct CurrencyList: View {
    @State private var searchText: String = ""
    @Binding var selectedTextTick: CurrencyInfo?
    @Binding var selectedCurrency: Bool

    let allCurrencies: [CurrencyInfo] = getCryptoCurrencies()

    var filteredCurrencies: [CurrencyInfo] {
        if searchText.isEmpty {
            return allCurrencies
        } else {
            return allCurrencies.filter {
                $0.code.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredCurrencies, id: \.self) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.code)
                            .font(.headline)
                        Text(item.symbol)
                        
                        Spacer()
                        
                        Text("USD: $\(String(format: "%.2f", item.rateUSD))")
                            .font(.caption)

                    }
                    
                    HStack{
                        Text(item.name)
                            .font(.subheadline)
                            
                        Spacer()
                        
                        Text("BDT: ৳\(String(format: "%.0f", item.rateBDT))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                    }
                                    }
                .padding(.vertical, 6)
                .onTapGesture {
                    selectedTextTick = item
                    selectedCurrency = false
                }
            }

            .searchable(text: $searchText)
            .navigationTitle("Select Crypto")
        }
    }
}



