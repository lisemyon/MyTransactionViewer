import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    progressView
                } else if viewModel.productSummaries.isEmpty && viewModel.errorMessage == nil {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle("Products")
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}

private extension ProductListView {
    var progressView: some View {
        ProgressView("Loading products...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var emptyView: some View {
        Text("No products available")
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var contentView: some View {
        List(viewModel.productSummaries) { product in
            NavigationLink(
                destination: TransactionListView(
                    sku: product.sku
                )) {
                    ProductRowView(product: product)
                }
        }
    }
}

#Preview {
    ProductListView()
}
