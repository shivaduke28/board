import SwiftUI
import SwiftUICore

struct AlbumListView: View {
    @EnvironmentObject var srfLibrary: SrfLibrary
    @State private var selectedAlbumId: AlbumId?

    var albums: [Album] {
        Array(srfLibrary.albums.values)
    }

    var body: some View {
        NavigationSplitView {
            List(albums, id: \.id, selection: $selectedAlbumId) { album in
                VStack(alignment: .leading) {
                    Text(album.metadata.title).font(.headline)
                    Text(album.metadata.artist).font(.caption)
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
