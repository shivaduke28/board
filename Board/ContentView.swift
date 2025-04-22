import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var srfLibrary = SrfLibrary()

    @State private var selectedSideBarItem: SidebarItem? = .tracks
    @State private var selectedSrfObject: SrfObject?

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedSideBarItem) { item in
                Button(item.title) {
                    selectedSideBarItem = item
                }
            }
            .frame(minWidth: 160)
        } detail: {
            VStack {
                HStack {
                    Button("Import mp3") {
                        selectAndImportMP3()
                    }
                    PlayerView(selectedSrfObject: $selectedSrfObject)
                    Spacer()
                }.padding()
                VStack {
                    switch selectedSideBarItem {
                    case .tracks:
                        TrackListView(srfLibrary: srfLibrary, selectedSrfObject: $selectedSrfObject)
                    case .artists:
                        ArtistListView(srfLibrary: srfLibrary)
                    case .albums:
                        AlbumListView(srfLibrary: srfLibrary)
                    case .none:
                        EmptyView()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            srfLibrary.loadLibrary()
        }

    }

    // サイドバーの項目定義
    enum SidebarItem: String, CaseIterable, Identifiable {
        case tracks, artists, albums
        var id: String { rawValue }
        var title: String {
            switch self {
            case .tracks: return "Tracks"
            case .artists: return "Artists"
            case .albums: return "Albums"
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
            let mp3Urls = panel.urls.flatMap { url -> [URL] in
                if url.hasDirectoryPath {
                    return FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)?
                        .compactMap { $0 as? URL }
                        .filter { $0.pathExtension.lowercased() == "mp3" } ?? []
                } else {
                    return [url]
                }
            }
            Task {
                await srfLibrary.importMP3Files(mp3Urls)
            }
        }
    }
}
