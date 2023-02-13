import SwiftUI

@main
struct TransactionalKeyValueStoreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init())
        }
    }
}
