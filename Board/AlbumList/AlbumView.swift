import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var srfLibrary: SrfLibrary
    @EnvironmentObject var audioPlayer: AudioPlayerModel
    @Binding var selectedAlbumId: AlbumId?

    @State private var isEditing: Bool = false
    @State private var editingMetaUrl: URL? = nil
    @State private var editingJsonText: String = ""

    var album: Album? {
        guard let id = selectedAlbumId else {
            return nil
        }
        return srfLibrary.albums[id]
    }

    var srfs: [Srf] {
        srfLibrary.srfs.values.filter { srf in
            srf.album.id == selectedAlbumId
        }
    }

    var body: some View {
        if let album {
            HStack {
                Text(album.metadata.title)
                    .font(.largeTitle)
                Text(album.metadata.artist)
                    .font(.title)
                Text(album.metadata.year.map(String.init) ?? "")
            }
            HStack {
                ForEach(album.metadata.artists, id: \.self) { artist in
                    Button(artist) {}
                }
            }

            Table(srfs) {
                TableColumn("") { srf in
                    Button {
                        audioPlayer.load(srf)
                        audioPlayer.play()
                    } label: {
                        Label("", systemImage: "play.fill").labelStyle(
                            .iconOnly
                        )
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
                TableColumn("Duration") { srf in
                    Text(srf.metadata.duration.mmss)
                }.width(60)
                TableColumn("") { srf in
                    Button {
                        edit(srf: srf)
                    } label: {
                        Label("", systemImage: "pencil").labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 20)
                }.width(20)
            }.sheet(isPresented: $isEditing) {
                MetaEditorView(
                    isPresented: $isEditing,
                    editingJsonText: $editingJsonText,
                    editingMetaUrl: $editingMetaUrl
                )
            }
        }
    }

    // track list と処理が重複しているのでmeta編集用のモデルを作るとよさそう
    // => sheetをContentViewにつけてしまうという手もあるかもしれない
    private func edit(srf: Srf) {
        let url = srf.url.appendingPathComponent(SrfLibrary.srfMetaFileName)
        editingMetaUrl = url
        editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        isEditing = true
    }
}
