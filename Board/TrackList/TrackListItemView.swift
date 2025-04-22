import SwiftUI

struct TrackListItemView: View {
    let srf: SrfObject
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
            Text(srf.meta.title).frame(maxWidth: .infinity, alignment: .leading)
            Text(srf.meta.artist).frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(srf.meta.artists, id: \.self) { artist in
                    Button(artist) {}
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            Button(srf.meta.album) {}.frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(srf.meta.remixers, id: \.self) { artist in
                    Button(artist) {}
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            Text(TrackListView.MsToMMSS(srf.meta.duration)).frame(width: 60, alignment: .leading)
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
