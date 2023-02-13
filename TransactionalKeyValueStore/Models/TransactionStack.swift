import Foundation

/// TransactionStack (Transactional Key Value Store) with the following API:
/// - SET <key> <value> // store the value for key
/// - GET <key>         // return the current value for key
/// - DELETE <key>      // remove the entry for key
/// - COUNT <value>     // return the number of keys that have the given value
/// - BEGIN             // start a new transaction
/// - COMMIT            // complete the current transaction
/// - ROLLBACK          // revert to state prior to BEGIN call
final class TransactionStack {
    var globalStore: [String: String] = [:]
    var transactions: [Transaction] = []

    func resetState() {
        globalStore = [:]
        transactions = []
    }
}

extension TransactionStack {
    func set(key: String, value: String) {
        if let activeTransaction = transactions.last {
            activeTransaction.store[key] = value
        } else {
            globalStore[key] = value
        }
    }

    func get(key: String) -> String {
        if let activeTransaction = transactions.last {
            return activeTransaction.store[key] ?? "key not set"
        } else {
            return globalStore[key] ?? "key not set"
        }
    }

    func delete(key: String) {
        if let activeTransaction = transactions.last {
            activeTransaction.store[key] = nil
        } else {
            globalStore[key] = nil
        }
    }

    func count(value: String) -> Int {
        if let activeTransaction = transactions.last {
            return activeTransaction.store.compactMapValues { $0 == value ? $0 : nil }.count
        } else {
            return globalStore.compactMapValues { $0 == value ? $0 : nil }.count
        }
    }

    func begin() {
        transactions.append(.init(store: transactions.last?.store ?? globalStore))
    }

    @discardableResult
    func commit() -> String? {
        if let activeTransaction = transactions.popLast() {
            if let nextTransaction = transactions.last {
                nextTransaction.store = activeTransaction.store
            } else {
                globalStore = activeTransaction.store
            }
            return nil
        } else {
            return "no transaction"
        }
    }

    @discardableResult
    func rollback() -> String? {
        if let activeTransaction = transactions.popLast() {
            activeTransaction.store.removeAll()
            return nil
        } else {
            return "no transaction"
        }
    }
}

