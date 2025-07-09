import Foundation

protocol DataProviderProtocol: Sendable {
    func getProductSummaries() async -> Result<[ProductSummary], DataServiceError>
    func getTransactions(for sku: String) async -> Result<[Transaction], DataServiceError>

    func convertToGBP(amount: Double, from currency: String) async -> Double?
}

actor DataProvider: DataProviderProtocol {
    private var transactions: [Transaction]?
    private var exchangeRates: [ExchangeRate]?

    private let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
    }

    func getProductSummaries() async -> Result<[ProductSummary], DataServiceError> {
        do {
            try await ensureDataLoaded()
        } catch {
            return .failure(error as? DataServiceError ?? .transactionParsingFailed)
        }

        guard let transactions = transactions, !transactions.isEmpty else {
            return .failure(.transactionParsingFailed)
        }

        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.sku })
        let summaries = groupedTransactions.map { sku, transactions in
            ProductSummary(sku: sku, transactionCount: transactions.count)
        }.sorted { $0.sku < $1.sku }

        return .success(summaries)
    }

    func getTransactions(for sku: String) async -> Result<[Transaction], DataServiceError> {
        do {
            try await ensureDataLoaded()
        } catch {
            return .failure(error as? DataServiceError ?? .transactionParsingFailed)
        }

        guard let transactions = transactions else {
            return .failure(.transactionParsingFailed)
        }

        let filteredTransactions = transactions.filter { $0.sku == sku }
        guard !filteredTransactions.isEmpty else {
            return .failure(.transactionParsingFailed)
        }

        return .success(filteredTransactions)
    }

    func convertToGBP(amount: Double, from currency: String) async -> Double? {
        try? await ensureDataLoaded()

        guard let exchangeRates = exchangeRates else {
            return nil
        }

        if currency == SharedConstants.currency {
            return amount
        }

        if let directRate = findDirectConversion(from: currency, to: SharedConstants.currency, in: exchangeRates) {
            return amount * directRate
        }

        if let indirectRate = findIndirectConversion(from: currency, to: SharedConstants.currency, in: exchangeRates) {
            return amount * indirectRate
        }

        return nil
    }
}

// MARK: - Private methods

private extension DataProvider {
    private func ensureDataLoaded() async throws {
        guard transactions == nil || exchangeRates == nil else { return }

        async let loadedTransactions = dataService.loadTransactions()
        async let loadedRates = dataService.loadExchangeRates()

        transactions = try await loadedTransactions
        exchangeRates = try await loadedRates
    }

    // MARK: - Private Currency Conversion Logic

    func findDirectConversion(from: String, to: String, in rates: [ExchangeRate]) -> Double? {
        rates.first { $0.from == from && $0.to == to }?.numericRate
    }

    func findIndirectConversion(from: String, to: String, in rates: [ExchangeRate]) -> Double? {
        for intermediateRate in rates {
            if intermediateRate.from == from {
                let intermediate = intermediateRate.to
                if let secondRate = findDirectConversion(from: intermediate, to: to, in: rates) {
                    return intermediateRate.numericRate * secondRate
                }
            }
        }
        return nil
    }
}
