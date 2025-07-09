import SwiftUI

struct TransactionRowView: View {
    let transactionWithGBP: TransactionWithGBP

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Amount")
                Spacer()
                Text(SharedConstants.currency)
            }
            .font(.caption)
            .foregroundColor(.secondary)

            HStack {
                Text(transactionWithGBP.transaction.amount)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(transactionWithGBP.transaction.currency)
                    .font(.title3)
                    .foregroundColor(.secondary)

                Spacer()

                Text(transactionWithGBP.gbpAmount != nil ? "£\(transactionWithGBP.gbpAmount!, specifier: "%.2f")" : "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

#Preview {
    let transaction = Transaction(amount: "100.00", currency: "USD", sku: "TEST")
    let transactionWithGBP = TransactionWithGBP(transaction: transaction, gbpAmount: 76.50)

    TransactionRowView(transactionWithGBP: transactionWithGBP)
        .padding()
}
