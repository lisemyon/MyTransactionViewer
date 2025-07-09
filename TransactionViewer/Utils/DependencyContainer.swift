import Foundation

/// Dependency Container for managing shared dependencies
final class DependencyContainer {
    static let shared = DependencyContainer()

    private let _dataProvider: DataProviderProtocol

    init(dataProvider: DataProviderProtocol = DataProvider()) {
        self._dataProvider = dataProvider
    }

    var dataProvider: DataProviderProtocol {
        return _dataProvider
    }
}

extension DependencyContainer {
    static func mock(dataProvider: DataProviderProtocol) -> DependencyContainer {
        return DependencyContainer(dataProvider: dataProvider)
    }
}
