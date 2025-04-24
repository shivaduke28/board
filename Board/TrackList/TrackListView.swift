import SwiftUI

struct TrackListView: View {
    @EnvironmentObject private var srfLibrary: SrfLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayerModel
    @EnvironmentObject private var srfMetadataEditor: SrfMetadataEditor

    @Binding var selectedAlbumId: AlbumId?
    @Binding var selectedSidebarItem: SidebarItem

    @State private var isEditing: Bool = false
    @State private var editingMetaUrl: URL? = nil
    @State private var editingJsonText: String = ""

    var srfs: [Srf] {
        Array(srfLibrary.srfs.values)
    }

    var body: some View {
        Table(srfs) {
            TableColumn("") { srf in
                Button {
                    audioPlayer.load(srf)
                    audioPlayer.play()
                } label: {
                    Label("", systemImage: "play.fill").labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .frame(width: 20)
            }.width(20)
            TableColumn("Title") { srf in
                Text(srf.metadata.title)
            }
            TableColumn("Artist") { srf in
                Text(srf.metadata.artist)
            }
            TableColumn("Artists") { srf in
                HStack {
                    ForEach(srf.metadata.artists, id: \.self) { artist in
                        Button(artist) {}
                    }
                }
            }
            TableColumn("Album") { srf in
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
                Text(srf.album.metadata.year.map(String.init) ?? "")
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
    }
}
