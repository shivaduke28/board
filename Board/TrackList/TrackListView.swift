import SwiftUI

struct TrackListView: View {
    @ObservedObject var viewModel: TrackListViewModel
    @State private var hoveredId: UUID? = nil

    var body: some View {
        Table(viewModel.srfs) {
            TableColumn("") { srf in
                Button {
                    viewModel.load(srf)
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
                Button(srf.album.metadata.title) {}
            }
            TableColumn("Duration") { srf in
                Text(srf.metadata.duration.mmss)
            }.width(60)
            TableColumn("Year") { srf in
                Text(srf.album.metadata.year.map(String.init) ?? "")
            }.width(60)
            TableColumn("") { srf in
                Button {
                    viewModel.edit(srf)
                } label: {
                    Label("", systemImage: "pencil").labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .frame(width: 20)
            }.width(20)
        }

        .sheet(isPresented: $viewModel.isEditing) {
            MetaEditorView(
                jsonText: $viewModel.editingJsonText,
                alertText: $viewModel.editingAlertText
            ) {
                viewModel.save()
            }
        }
    }
}
