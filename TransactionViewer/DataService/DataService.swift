import Foundation

protocol DataServiceProtocol: Sendable {
    func loadTransactions() async throws -> [Transaction]
    func loadExchangeRates() async throws -> [ExchangeRate]
}

final class DataService: DataServiceProtocol, Sendable {
    private let propertyListDecoder = PropertyListDecoder()

    func loadTransactions() async throws -> [Transaction] {
        guard let path = Bundle.main.path(forResource: "transactions", ofType: "plist") else {
            throw DataServiceError.transactionFileNotFound
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let transactions = try propertyListDecoder.decode([Transaction].self, from: data)

        return transactions
    }

    func loadExchangeRates() async throws -> [ExchangeRate] {
        guard let path = Bundle.main.path(forResource: "rates", ofType: "plist") else {
            throw DataServiceError.ratesFileNotFound
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let rates = try propertyListDecoder.decode([ExchangeRate].self, from: data)

        return rates
    }
}
