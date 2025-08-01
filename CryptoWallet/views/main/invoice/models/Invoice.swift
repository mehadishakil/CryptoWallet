//
//  Invoice.swift
//  CryptoWallet
//
//  Created by Mehadi Hasan on 2/7/25.
//

import Foundation
import SwiftData




//// Function to generate the invoice number
//func generateInvoiceNumber() -> String {
//    let letters = String((0..<2).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()! })
//    let numbers = String((0..<5).map { _ in "0123456789".randomElement()! })
//    return letters + numbers
//}

@Model
final class Invoice {
    enum Status: String, Codable {
        case paid
        case pending
        case overdue
    }
    
    
    var id: String
    var invoiceNumber: String
    var currency: String
    var invoiceDate: Date
    var paymentDue: String
    var clientName: String
    var items: [InvoiceItem]
    var status: Status
    
    var totalAmount: Double {
        items.reduce(0) {$0 + $1.amount  }
    }
    
    
    var imageName: String {
        switch status {
        case .paid:
            "checkmark"
        case .pending:
            "hourglass"
        case .overdue:
            "clock.badge.exclamationmark.fill"
        }
        
    }
    
    
    init(id: String = UUID().uuidString, invoiceNumber: String, currency: String, invoiceDate: Date = Date(), paymentDue: String, clientName: String, items: [InvoiceItem], status: Status = .pending) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.currency = currency
        self.invoiceDate = invoiceDate
        self.paymentDue = paymentDue
        self.clientName = clientName
        self.items = items
        self.status = status
    }
    
}

struct InvoiceItem: Identifiable, Codable {
    
    var id = UUID().uuidString
    var name: String
    var quantity: Int
    var description: String
    var amount: Double
}

struct InvoiceFile {
    let id: String
    let date: Date
    let items: [InvoiceFileItem]
    let totalAmount: Double
}

struct InvoiceFileItem {
    let description: String
    let quantity: Int
    let unitPrice: Double
    
    var total: Double {
        return Double(quantity) * unitPrice
    }
}
