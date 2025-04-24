import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                Button("Import mp3") {
                    viewModel.selectAndImportMP3()
                }.padding(.horizontal)
                Divider()
                List(SidebarItem.allCases) { item in
                    Button(item.title) {
                        viewModel.selectedSideBarItem = item
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
                    switch viewModel.selectedSideBarItem {
                    case .tracks:
                        TrackListView(viewModel: viewModel.trackList)
                    case .artists:
                        ArtistListView()
                    case .albums:
                        AlbumListView()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadLibrary()
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
    ContentView(
        viewModel: .init(srfLibrary: srfLibrary, audioPlayer: audioPlayer)
    )
    .environmentObject(audioPlayer)
    .environmentObject(srfLibrary)
}
