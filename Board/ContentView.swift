import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @StateObject private var srfLibrary = SrfLibrary()
    @State private var selectedMetaID: UUID? = nil

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
                ForEach(srfLibrary.srfMetaDatas) { meta in
                    HStack {
                        Text(meta.title).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.artists.joined(separator: ", ")).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.album).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            srfLibrary.loadLibrary()
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
