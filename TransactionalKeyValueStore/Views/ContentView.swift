import SwiftUI

struct ContentView: View {

    @ObservedObject private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Spacer()
            TextEditor(text: $viewModel.consoleText)
                .accessibilityIdentifier(viewModel.consoleAccessibilityIdentifier)
                .textSelection(.disabled)

            ForEach($viewModel.inputModels) { $inputModel in
                HStack {
                    ForEach(0..<inputModel.textFields.count, id: \.self) { index in
                        TextField("", text: $inputModel.textFields[index], prompt: Text(inputModel.kind.placeholders[index]))
                            .accessibilityIdentifier(inputModel.textFieldAccessibilityIdentifier(at: index))
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                    }
                    Button {
                        viewModel.actionFor(inputModel.kind)
                    } label: {
                        Text(inputModel.kind.rawValue)
                    }
                    .accessibilityIdentifier(inputModel.buttonAccessibilityIdentifier)
                    .buttonStyle(.borderedProminent)
                }
            }

            HStack {
                ForEach(0..<viewModel.commandButtons.count) { index in
                    let buttonKind = viewModel.commandButtons[index]
                    Button {
                        viewModel.actionFor(buttonKind)
                    } label: {
                        Text(buttonKind.rawValue)
                    }
                    .accessibilityIdentifier(buttonKind.accessibilityIdentifier)
                    .buttonStyle(.borderedProminent)
                }
            }

            HStack {
                ForEach(0..<viewModel.additionalCommandButtons.count) { index in
                    let buttonKind = viewModel.additionalCommandButtons[index]
                    Button {
                        viewModel.actionFor(buttonKind)
                    } label: {
                        Text(buttonKind.rawValue)
                    }
                    .accessibilityIdentifier(buttonKind.accessibilityIdentifier)
                    .buttonStyle(.borderedProminent)
                }
            }
            Spacer(minLength: 30)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
