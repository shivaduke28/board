import SwiftUI
struct TrackListView: View {
    @ObservedObject var viewModel: TrackListViewModel

    var body: some View {
        VStack {
            HStack {
                Text("").frame(maxWidth: .infinity, alignment: .leading)
                Text("Title").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Artist").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Artists").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Album").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Remixers").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Duration").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            Divider()
            List {
                ForEach(viewModel.srfs) { srf in
                    let meta = srf.meta
                    HStack {
                        Button("Load") {
                            viewModel.load(srf)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.title).frame(maxWidth: .infinity, alignment: .leading)
                        Text(meta.artist).frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            ForEach(meta.artists, id: \.self) { artist in
                                Button(artist) {}
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Button(meta.album) {}.frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            ForEach(meta.remixers, id: \.self) { artist in
                                Button(artist) {}
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Text(TrackListView.MsToMMSS(meta.duration)).frame(maxWidth: .infinity, alignment: .leading)
                        Button("Edit") { viewModel.edit(srf) }
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $viewModel.isEditing) {
            MetaEditorView(jsonText: $viewModel.editingJsonText, alertText: $viewModel.editingAlertText) {
                viewModel.save()
            }
        }
    }

    private static func MsToMMSS(_ ms: Int) -> String {
        let totalSeconds = ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
