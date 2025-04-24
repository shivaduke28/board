import Foundation
import SwiftUI

class SrfMetadataEditor: ObservableObject {
    private let srfLibrary: SrfLibrary

    @Published var isPresented: Bool = false
    @Published var editingJsonText: String = ""
    private var editingMetaUrl: URL? = nil

    init(srfLibrary: SrfLibrary) {
        self.srfLibrary = srfLibrary
    }

    func edit(srf: Srf) {
        let url = srf.url.appendingPathComponent(SrfLibrary.srfMetaFileName)
        editingMetaUrl = url
        editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        isPresented = true
    }

    func save() throws {
        if let url = editingMetaUrl {
            try srfLibrary.updateSrf(metaUrl: url, json: editingJsonText)
            editingMetaUrl = nil
            // TODO: ここでなんらかの更新を行わないとViewに反映されなさそう
            isPresented = false
        }
    }
}

struct MetaEditorView: View {
    @ObservedObject var srfMetadataEditor: SrfMetadataEditor
    @State private var editingAlertText: String = ""

    private func save() {
        do {
            try srfMetadataEditor.save()
        } catch {
            print(error.localizedDescription)
            editingAlertText = "Save failed."
        }
    }

    var body: some View {
        VStack {
            Text("Edit Meta File")
                .font(.headline)
            Text(editingAlertText)
                .foregroundColor(.red)
            PlainNSTextView(text: $srfMetadataEditor.editingJsonText)
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
