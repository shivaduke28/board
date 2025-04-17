import Foundation
import SwiftUI

struct MetaEditorView: View {
    @Binding var jsonText: String
    @Binding var alertText: String
    var onSave: () -> Void

    var body: some View {
        VStack {
            Text("Edit meta.json")
                .font(.headline)
            Text(alertText)
                .foregroundColor(.red)
            PlainNSTextView(text: $jsonText)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray)
                .padding()
            HStack {
                Spacer()
                Button("Save") {
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}
