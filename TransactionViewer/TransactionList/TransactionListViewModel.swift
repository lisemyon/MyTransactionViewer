import Combine
import Foundation

final class TransactionListViewModel: ObservableObject {
    @Published var transactionsWithGBP: [TransactionWithGBP] = []
    @Published var totalInGBP: Double = 0.0
    @Published var isLoading = true
    @Published var errorMessage: String?

    let sku: String
    private let dataProvider: DataProviderProtocol
    private var loadingTask: Task<Void, Never>?

    init(sku: String, dataProvider: DataProviderProtocol = DependencyContainer.shared.dataProvider) {
        self.sku = sku
        self.dataProvider = dataProvider
        loadTransactions()
    }

    deinit {
        loadingTask?.cancel()
    }

    private func loadTransactions() {
        loadingTask?.cancel() // Cancel any existing task

        loadingTask = Task { [weak self] in
            guard let self = self else { return }

            let result = await self.dataProvider.getTransactions(for: self.sku)

            switch result {
            case .success(let loadedTransactions):
                await self.convertTransactionsToGBP(loadedTransactions)
            case .failure(let error):
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }

            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    private func convertTransactionsToGBP(_ transactions: [Transaction]) async {
        let (transactionsWithGBP, total) = await withTaskGroup(of: TransactionWithGBP.self) { group in
            for transaction in transactions {
                group.addTask { [weak self] in
                    guard let self = self else {
                        return TransactionWithGBP(transaction: transaction, gbpAmount: nil)
                    }

                    let gbpAmount = await self.dataProvider.convertToGBP(
                        amount: transaction.numericAmount,
                        from: transaction.currency
                    )

                    return TransactionWithGBP(transaction: transaction, gbpAmount: gbpAmount)
                }
            }

            // Calculate both array and total in one pass
            return await group.reduce(into: ([TransactionWithGBP](), 0.0)) { result, transactionWithGBP in
                result.0.append(transactionWithGBP)
                if let gbpAmount = transactionWithGBP.gbpAmount {
                    result.1 += gbpAmount
                }
            }
        }

        await MainActor.run {
            self.transactionsWithGBP = transactionsWithGBP
            self.totalInGBP = total
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
