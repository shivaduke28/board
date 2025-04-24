import SwiftUI

struct TrackListItemView: View {
    let srf: Srf
    let viewModel: TrackListViewModel

    var body: some View {
        HStack {
            Button(action: {
                viewModel.load(srf)
            }) {
                Label("", systemImage: "play.fill").labelStyle(.iconOnly)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20)
            Text(srf.metadata.title).frame(maxWidth: .infinity, alignment: .leading)
            Text(srf.metadata.artist).frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(srf.metadata.artists, id: \.self) { artist in
                    Button(artist) {}
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            Button(srf.album.metadata.title) {}.frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(srf.metadata.remixers, id: \.self) { artist in
                    Button(artist) {}
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            Text(srf.metadata.duration.mmss).frame(width: 60, alignment: .leading)
            Button(action: {
                viewModel.edit(srf)
            }) {
                Label("", systemImage: "pencil").labelStyle(.iconOnly)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20)
        }
    }
}
