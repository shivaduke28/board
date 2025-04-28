import SwiftUI

struct TrackListView: View {
    @State private var sortOrder = [
        KeyPathComparator(\Srf.metadata.title),
        KeyPathComparator(\Srf.metadata.artist),
        KeyPathComparator(\Srf.album.metadata.title),
    ]
    @EnvironmentObject private var srfLibrary: SrfLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayerController
    @EnvironmentObject private var srfMetadataEditor: MetadataEditor

    @Binding var selectedAlbumId: AlbumId?
    @Binding var selectedSidebarItem: SidebarItem
    @State private var filterText = ""
    @State private var isEditing: Bool = false
    @State private var editingMetaUrl: URL? = nil
    @State private var editingJsonText: String = ""

    static func filterByText(srf: Srf, filterText: String) -> Bool {
        if filterText.isEmpty {
            return true
        }
        return srf.metadata.title.localizedCaseInsensitiveContains(filterText)
            || srf.metadata.artist.localizedCaseInsensitiveContains(filterText)
            || srf.album.metadata.title.localizedCaseInsensitiveContains(
                filterText
            )
            || false
    }

    var body: some View {
        let _ = Self._printChanges()
        let srfs = Array(
            srfLibrary.srfs.values
                .filter {
                    TrackListView.filterByText(srf: $0, filterText: filterText)
                }
        )
        .sorted(using: sortOrder)
        Table(srfs, sortOrder: $sortOrder) {
            TableColumn("") { srf in
                Button {
                    audioPlayer.load(srf: srf)
                } label: {
                    Label("", systemImage: "play.fill").labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .frame(width: 20)
            }.width(20)
            TableColumn("#") { srf in
                Text(srf.metadata.trackNumber.toText)
            }.width(20)
            TableColumn("Title", value: \.metadata.title)
            TableColumn("Artist", value: \.metadata.artist)
            TableColumn("Artists") { srf in
                HStack {
                    ForEach(srf.metadata.artists, id: \.self) { artist in
                        Button(artist) {}
                    }
                }
            }
            TableColumn("Album", value: \.album.metadata.title) { srf in
                Button(srf.album.metadata.title) {
                    selectedAlbumId = srf.album.id
                    selectedSidebarItem = .albums
                }
            }
            TableColumn("Remixers") { srf in
                HStack {
                    ForEach(srf.metadata.remixers, id: \.self) { artist in
                        Button(artist) {}
                    }
                }
            }
            TableColumn("Duration") { srf in
                Text(srf.metadata.duration.mmss)
            }.width(60)
            TableColumn("Year") { srf in
                Text(srf.album.metadata.year.toText)
            }.width(60)
            TableColumn("") { srf in
                Button {
                    srfMetadataEditor.edit(srf: srf)
                } label: {
                    Label("", systemImage: "pencil").labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .frame(width: 20)
            }.width(20)
        }
        // TODO: isPresentedを操作することでフォーカスを切り替えられるのでSceneで.commandsを使って⌘+Fでフォーカスするとよさそう
        .searchable(text: $filterText)
        // ソート時にハングしないようにするworkaround
        // https://blog.dnpp.org/broken_swiftui_table_on_macos
        .id(sortOrder)
    }
}
