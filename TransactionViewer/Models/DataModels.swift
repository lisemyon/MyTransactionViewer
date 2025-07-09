import Foundation

struct Transaction: Identifiable, Decodable {
    let id = UUID()
    let amount: String
    let currency: String
    let sku: String

    var numericAmount: Double {
        Double(amount) ?? .zero
    }
}

struct ExchangeRate: Decodable {
    let from: String
    let rate: String
    let to: String

    var numericRate: Double {
        Double(rate) ?? .zero
    }
}

struct ProductSummary: Identifiable {
    let id = UUID()
    let sku: String
    let transactionCount: Int
}

struct TransactionWithGBP: Identifiable {
    let id = UUID()
    let transaction: Transaction
    let gbpAmount: Double?
    
    init(transaction: Transaction, gbpAmount: Double?) {
        self.transaction = transaction
        self.gbpAmount = gbpAmount
    }
}
