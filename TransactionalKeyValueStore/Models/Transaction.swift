import Foundation

final class Transaction {
    var store: [String: String]

    init(store: [String: String] = [:]) {
        self.store = store
    }
}
