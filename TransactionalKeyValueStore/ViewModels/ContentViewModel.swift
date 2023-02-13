import SwiftUI

@MainActor final class ContentViewModel: ObservableObject {

    class InputViewModel: ObservableObject, Identifiable {
        enum Kind: String {
            case set = "SET"
            case get = "GET"
            case delete = "DELETE"
            case count = "COUNT"

            var placeholders: [String] {
                switch self {
                case .set:
                    return ["KEY", "VALUE"]
                case .get:
                    return ["KEY"]
                case .delete:
                    return ["KEY"]
                case .count:
                    return ["VALUE"]
                }
            }
        }

        let kind: Kind
        @Published var textFields: [String]

        init(kind: Kind, textFields: [String]) {
            self.kind = kind
            self.textFields = textFields
        }

        var id: String {
            kind.rawValue
        }

        var buttonAccessibilityIdentifier: String {
            kind.rawValue + " BUTTON"
        }

        func textFieldAccessibilityIdentifier(at index: Int) -> String {
            guard index < kind.placeholders.count else {
                return kind.rawValue + " TEXTFIELD"
            }
            return kind.rawValue + " " + kind.placeholders[index] + " TEXTFIELD"
        }
    }

    enum ButtonKind: String {
        case begin = "BEGIN"
        case commit = "COMMIT"
        case rollback = "ROLLBACK"
        case clearConsole = "CLEAR CONSOLE"
        case resetState = "RESET STATE"

        var accessibilityIdentifier: String {
            rawValue + " BUTTON"
        }
    }

    private let transactionStack = TransactionStack()

    public let consoleAccessibilityIdentifier = "CONSOLE TEXT EDITOR"
    @Published var consoleText: String = ""

    @Published var inputModels = [
        InputViewModel(kind: .set, textFields: ["", ""]),
        InputViewModel(kind: .get, textFields: [""]),
        InputViewModel(kind: .delete, textFields: [""]),
        InputViewModel(kind: .count, textFields: [""])
    ]

    @Published var commandButtons: [ButtonKind] = [
        .begin,
        .commit,
        .rollback
    ]

    @Published var additionalCommandButtons: [ButtonKind] = [
        .clearConsole,
        .resetState
    ]

    // MARK: - Public Methods
    public func actionFor(_ kind: InputViewModel.Kind) {
        guard let input = inputModels.first(where: { $0.kind == kind }), !input.textFields.isEmpty else {
            return
        }
        switch kind {
        case .set:
            guard input.textFields.count == 2 else {
                return
            }
            set(key: input.textFields[0], value: input.textFields[1])
        case .get:
            get(key: input.textFields[0])
        case .delete:
            delete(key: input.textFields[0])
        case .count:
            count(value: input.textFields[0])
        }
    }

    public func actionFor(_ kind: ButtonKind) {
        switch kind {
        case .begin:
            begin()
        case .commit:
            commit()
        case .rollback:
            rollback()
        case .clearConsole:
            clearConsole()
        case .resetState:
            resetState()
        }
    }

    // MARK: - Private Methods
    private func set(key: String, value: String) {
        transactionStack.set(key: key, value: value)
        consoleText += "> SET \(key) \(value)\n"
    }
    
    private func get(key: String) {
        let value = transactionStack.get(key: key)
        consoleText += "> GET \(key)\n\(value)\n"
    }
    
    private func delete(key: String) {
        transactionStack.delete(key: key)
        consoleText += "> DELETE \(key)\n"
    }
    
    private func count(value: String) {
        let count = transactionStack.count(value: value)
        consoleText += "> COUNT \(value)\n\(count)\n"
    }

    private func begin() {
        transactionStack.begin()
        consoleText += "> BEGIN\n"
    }
    
    private func commit() {
        let commitError = transactionStack.commit()
        consoleText += "> COMMIT\n"
        if let commitError = commitError {
            consoleText += "\(commitError)\n"
        }
    }
    
    private func rollback() {
        let rollbackError = transactionStack.rollback()
        consoleText += "> ROLLBACK\n"
        if let rollbackError = rollbackError {
            consoleText += "\(rollbackError)\n"
        }
    }

    // MARK: - Additional QOL Helpers
    private func clearConsole() {
        consoleText = ""
    }
    
    private func resetState() {
        clearConsole()
        inputModels = [
            InputViewModel(kind: .set, textFields: ["", ""]),
            InputViewModel(kind: .get, textFields: [""]),
            InputViewModel(kind: .delete, textFields: [""]),
            InputViewModel(kind: .count, textFields: [""])
        ]
        transactionStack.resetState()
    }
}
