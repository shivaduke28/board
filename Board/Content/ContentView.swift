import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading){
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
                    AudioPlayerView(viewModel: viewModel.audioPlayer)
                }.padding()
                VStack {
                    switch viewModel.selectedSideBarItem {
                    case .tracks:
                        TrackListView(viewModel: viewModel.trackList)
                    case .artists:
                        ArtistListView(srfLibrary: viewModel.srfLibrary)
                    case .albums:
                        AlbumListView(srfLibrary: viewModel.srfLibrary)
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
    ContentView(viewModel: .init())
}
