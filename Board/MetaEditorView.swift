import Foundation
import SwiftUI

struct MetaEditorView: View {
    @EnvironmentObject var srfLibrary: SrfLibrary
    @Binding var isPresented: Bool
    @Binding var editingJsonText: String
    @Binding var editingMetaUrl: URL?
    @State private var editingAlertText: String = ""

    private func save() {
        do {
            if let url = editingMetaUrl {
                try srfLibrary.updateSrf(metaUrl: url, json: editingJsonText)
                srfLibrary.loadLibrary()
            }
        } catch {
            print(error.localizedDescription)
            editingAlertText = "Save failed."
        }
    }

    var body: some View {
        VStack {
            Text("Edit meta.json")
                .font(.headline)
            Text(editingAlertText)
                .foregroundColor(.red)
            PlainNSTextView(text: $editingJsonText)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray)
                .padding()
            HStack {
                Spacer()
                Button("Save") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}
