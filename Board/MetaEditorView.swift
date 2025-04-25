import Foundation
import SwiftUI

enum MetaEditorTarget {
    case srf, album
}

class MetadataEditor: ObservableObject {
    private let srfLibrary: SrfLibrary

    @Published var isPresented: Bool = false
    @Published var editingJsonText: String = ""
    private(set) var target: MetaEditorTarget = .srf
    var isPresentedPublisher: Published<Bool>.Publisher {
        $isPresented
    }
    var editingJsonTextPublisher: Published<String>.Publisher {
        $editingJsonText
    }

    private var editingMetaUrl: URL? = nil

    init(srfLibrary: SrfLibrary) {
        self.srfLibrary = srfLibrary
    }

    func edit(srf: Srf) {
        let url = srf.url.appendingPathComponent(SrfLibrary.srfMetaFileName)
        editingMetaUrl = url
        editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        target = .srf
        isPresented = true
    }

    func edit(album: Album) {
        target = .album
        let url = album.metadataUrl
        editingMetaUrl = url
        editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        isPresented = true
    }

    func save() throws {
        switch target {
        case .srf:
            if let url = editingMetaUrl {
                try srfLibrary.updateSrf(metaUrl: url, json: editingJsonText)
                editingMetaUrl = nil
            }
        case .album:
            if let url = editingMetaUrl {
                try srfLibrary.updateAlbum(metaUrl: url, json: editingJsonText)
                editingMetaUrl = nil
            }
            break
        }
        // TODO: 全てのViewが初期化されてUUIDも変わってしまうのをやめたい
        srfLibrary.loadLibrary()
        isPresented = false
    }
}

struct MetaEditorView: View {
    @ObservedObject var metadataEditor: MetadataEditor
    @State private var editingAlertText: String = ""

    private func save() {
        do {
            try metadataEditor.save()
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
            PlainNSTextView(text: $metadataEditor.editingJsonText)
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
