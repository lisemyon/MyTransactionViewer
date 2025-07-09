import SwiftUI

struct ProductRowView: View {
    let product: ProductSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.sku)
                .font(.headline)
                .foregroundColor(.primary)

            Text("\(product.transactionCount) transaction\(product.transactionCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ProductRowView(product: ProductSummary(sku: "J4064", transactionCount: 5))
        .padding()
}
