import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var srfLibrary = SrfLibrary()
    @State private var selectedMetaID: UUID? = nil

    @State private var isEditing = false
    @State private var editingMetaUrl: URL?
    @State private var editingJsonText: String = ""
    @State private var editingAlertText: String = ""

    var body: some View {
        VStack {
            Button("Import mp3") {
                selectAndImportMP3()
            }
            HStack {
                Text("title").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("artists").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("album").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("remixers").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
            List(selection: $selectedMetaID) {
                ForEach(srfLibrary.srfs) { srf in
                    let meta = srf.meta
                    HStack {
                        Text(meta.title).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.artists.joined(separator: ", ")).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.album).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.remixers.joined(separator: ", ")).frame(maxWidth: .infinity, alignment: .leading)
                        Button(
                            "Edit",
                            action: {
                                let url = srf.url.appendingPathComponent("meta.json")
                                editingMetaUrl = url
                                editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                                isEditing = true
                            }
                        )
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            srfLibrary.loadLibrary()
        }
        .sheet(isPresented: $isEditing) {
            MetaEditorView(jsonText: $editingJsonText, alertText: $editingAlertText) {
                do {
                    if let url = editingMetaUrl {
                        try srfLibrary.updateSrf(metaUrl: url, json: editingJsonText)
                        isEditing = false
                        srfLibrary.loadLibrary()
                    }
                } catch {
                    print(error.localizedDescription)
                    editingAlertText = "Save failed."
                }
            }
        }
    }

    private func selectAndImportMP3() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.begin { result in
            guard result == .OK else { return }
            for url in panel.urls {
                if url.hasDirectoryPath {
                    if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) {
                        for case let fileURL as URL in enumerator {
                            if fileURL.pathExtension.lowercased() == "mp3" {
                                Task {
                                    await importMP3(fileURL)
                                }
                            }
                        }
                    }
                } else {
                    Task {
                        await importMP3(url)
                    }
                }
            }
        }
    }

    private func importMP3(_ url: URL) async {
        if let trackAsset = try? await TrackAssetLoader.createTrackAsset(url: url) {
            srfLibrary.createSrf(asset: trackAsset)
            // 複数importしたときに無駄がありそう
            srfLibrary.loadLibrary()
        }
    }
}
