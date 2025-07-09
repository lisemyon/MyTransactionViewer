import Combine
import Foundation

final class ProductListViewModel: ObservableObject {
    @Published var productSummaries: [ProductSummary] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let dataProvider: DataProviderProtocol
    private var loadingTask: Task<Void, Never>?

    init(dataProvider: DataProviderProtocol = DependencyContainer.shared.dataProvider) {
        self.dataProvider = dataProvider
        loadProducts()
    }

    deinit {
        loadingTask?.cancel()
    }

    func dismissError() {
        errorMessage = nil
    }

    private func loadProducts() {
        loadingTask?.cancel() // Cancel any existing task

        loadingTask = Task { [weak self] in
            guard let self = self else { return }

            let result = await self.dataProvider.getProductSummaries()

            await MainActor.run {
                switch result {
                case .success(let summaries):
                    self.productSummaries = summaries
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
}
