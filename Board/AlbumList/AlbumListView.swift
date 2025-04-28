import SwiftUI
import SwiftUICore

struct AlbumListView: View {
    @EnvironmentObject var srfLibrary: SrfLibrary
    @Binding var selectedAlbumId: AlbumId?
    @State private var filterText = ""

    static func fliterByText(album: Album, filterText: String) -> Bool {
        if filterText.isEmpty {
            return true
        }

        return album.metadata.title.localizedCaseInsensitiveContains(filterText)
            || album.metadata.artist.localizedCaseInsensitiveContains(
                filterText
            )
    }

    var body: some View {
        let _ = Self._printChanges()
        let albums = Array(
            srfLibrary.albums.values.filter {
                Self.fliterByText(album: $0, filterText: filterText)
            }.sorted { $0.metadata.title < $1.metadata.title }
        )
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
        // NOTE: .searchableは場所がtoolBarとsideBarしかない
        // scroll viewの上におきたい場合は自作のViewを用意する方が良さそう
        .searchable(text: $filterText)
    }

    func toString(_ num: Int?) -> String {
        num.map(String.init) ?? ""
    }
}
