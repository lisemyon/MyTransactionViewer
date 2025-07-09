import SwiftUI

struct TransactionListView: View {
    @StateObject private var viewModel: TransactionListViewModel

    init(sku: String) {
        _viewModel = StateObject(wrappedValue: TransactionListViewModel(sku: sku))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                progressView
            } else if viewModel.transactionsWithGBP.isEmpty && viewModel.errorMessage == nil {
                emptyView
            } else {
                content
            }
        }
        .navigationTitle("Transactions: \(viewModel.sku)")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

private extension TransactionListView {
    var content: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.transactionsWithGBP) { transactionWithGBP in
                    TransactionRowView(transactionWithGBP: transactionWithGBP)
                }
            }

            TotalSummaryView(totalGBP: viewModel.totalInGBP)
        }
    }

    var progressView: some View {
        ProgressView("Loading transactions...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var emptyView: some View {
        Text("No transactions available")
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        TransactionListView(sku: "J4064")
    }
}
