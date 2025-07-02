//
//   DateFormatter+Extensions.swift
//  CryptoWallet
//
//  Created by Mehadi Hasan on 2/7/25.
//
import Foundation

extension DateFormatter {
    static let sharedDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
