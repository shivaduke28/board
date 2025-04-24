import SwiftUI
import SwiftUICore

struct AlbumListView: View {
    @EnvironmentObject var srfLibrary: SrfLibrary
    @Binding var selectedAlbumId: AlbumId?

    var albums: [Album] {
        Array(srfLibrary.albums.values)
    }

    var body: some View {
        NavigationSplitView {
            ScrollViewReader { proxy in
                List(albums, id: \.id, selection: $selectedAlbumId) { album in
                    VStack(alignment: .leading) {
                        Text(album.metadata.title).font(.headline)
                        Text(album.metadata.artist).font(.caption)
                    }.id(album.id)
                }.onAppear {
                    if let id = selectedAlbumId {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        } detail: {
            AlbumView(selectedAlbumId: $selectedAlbumId)
        }
    }

    func toString(_ num: Int?) -> String {
        num.map(String.init) ?? ""
    }
}
