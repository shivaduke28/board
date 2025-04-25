import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var srfLibrary: SrfLibrary
    @EnvironmentObject var audioPlayer: AudioPlayerController
    @EnvironmentObject private var srfMetadataEditor: SrfMetadataEditor

    @Binding var selectedAlbumId: AlbumId?

    var album: Album? {
        guard let id = selectedAlbumId else {
            return nil
        }
        return srfLibrary.albums[id]
    }

    var srfs: [Srf] {
        srfLibrary.srfs.values.filter { srf in
            srf.album.id == selectedAlbumId
        }.sorted{ ($0.metadata.trackNumber ?? 0) < ($1.metadata.trackNumber ?? 0)}
    }

    var body: some View {
        let _ = Self._printChanges()

        if let album {
            HStack {
                Text(album.metadata.title)
                    .font(.largeTitle)
                Text(album.metadata.artist)
                    .font(.title)
                Text(album.metadata.year.toText)
            }
            HStack {
                ForEach(album.metadata.artists, id: \.self) { artist in
                    Button(artist) {}
                }
            }

            Table(srfs) {
                TableColumn("") { srf in
                    Button {
                        audioPlayer.load(srf: srf)
                    } label: {
                        Label("", systemImage: "play.fill").labelStyle(
                            .iconOnly
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(width: 20)
                }.width(20)
                TableColumn("#") { srf in
                    Text(srf.metadata.trackNumber.toText)
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
}
