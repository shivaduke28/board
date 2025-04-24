import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var trackAssetImporter: TrackAssetImporter
    @EnvironmentObject var srfLibrary: SrfLibrary
    @EnvironmentObject var srfMetadataEditor: SrfMetadataEditor
    @State private var selectedSideBarItem: SidebarItem = .tracks
    @State private var selectedAlbumId: AlbumId?

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                Button("Import mp3") {
                    trackAssetImporter.selectAndImportMP3()
                }.padding(.horizontal)
                Divider()
                List(SidebarItem.allCases) { item in
                    Button(item.title) {
                        selectedSideBarItem = item
                    }
                }
            }
            .frame(minWidth: 160)
        } detail: {
            VStack {
                HStack {
                    AudioPlayerView()
                }.padding()
                VStack {
                    switch selectedSideBarItem {
                    case .tracks:
                        TrackListView(selectedAlbumId: $selectedAlbumId, selectedSidebarItem: $selectedSideBarItem)
                    case .artists:
                        ArtistListView()
                    case .albums:
                        AlbumListView(selectedAlbumId: $selectedAlbumId)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            srfLibrary.loadLibrary()
        }
        .sheet(isPresented: $srfMetadataEditor.isPresented) {
            MetaEditorView(srfMetadataEditor: srfMetadataEditor)
        }
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

#Preview {
    let audioPlayer = AudioPlayerModel()
    let srfLibrary = SrfLibrary()
    let trackAssetImporter = TrackAssetImporter(srfLibrary: srfLibrary)
    ContentView()
    .environmentObject(audioPlayer)
    .environmentObject(srfLibrary)
    .environmentObject(trackAssetImporter)
}
