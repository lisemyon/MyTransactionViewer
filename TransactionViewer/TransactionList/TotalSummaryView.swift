import SwiftUI

struct TotalSummaryView: View {
    let totalGBP: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text("Total in GBP")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("£\(totalGBP, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    TotalSummaryView(totalGBP: 156.78)
}
