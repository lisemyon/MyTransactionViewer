import Foundation

enum DataServiceError: Error, LocalizedError {
    case transactionFileNotFound
    case ratesFileNotFound
    case transactionParsingFailed

    var errorDescription: String? {
        switch self {
        case .transactionFileNotFound:
            return "Transaction data file not found"
        case .ratesFileNotFound:
            return "Exchange rates file not found"
        case .transactionParsingFailed:
            return "Failed to parse transaction data"
        }
    }
}
