import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var srfLibrary = SrfLibrary()
    @State private var selectedMetaID: UUID? = nil

    @State private var isEditing = false
    @State private var editingMetaURL: URL?
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
            }
            Divider()
            List(selection: $selectedMetaID) {
                ForEach(srfLibrary.srfs) { srf in
                    let meta = srf.meta
                    HStack {
                        Text(meta.title).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.artists.joined(separator: ", ")).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.album).frame(maxWidth: .infinity, alignment: .leading)
                        Button("Edit", action: {
                            let url = srf.url.appendingPathComponent("meta.json")
                            editingMetaURL = url
                            editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                            isEditing = true
                        })
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
                    if let url = editingMetaURL {
                        try srfLibrary.updateSrf(url: url, json: editingJsonText)
                        isEditing = false
                        srfLibrary.loadLibrary()
                    }
                } catch {
                    editingAlertText = "Save failed."
                }
            }
        }
    }

    private func selectAndImportMP3() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { result in
            if result == .OK, let url = panel.url {
                Task {
                    do {
                        let trackAsset = try await TrackAssetLoader.createTrackAsset(url: url)
                        srfLibrary.createSrf(asset: trackAsset)
                        srfLibrary.loadLibrary()
                    } catch {
                        print("エラー: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
