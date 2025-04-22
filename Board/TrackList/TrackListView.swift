import SwiftUI

struct TrackListView: View {
    @ObservedObject var viewModel: TrackListViewModel
    @State private var hoveredId: UUID? = nil

    var body: some View {
        VStack {
            HStack {
                Text("").fontWeight(.bold).frame(width: 20)
                Text("Title").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Artist").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Artists").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Album").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Remixers").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Duration").fontWeight(.bold).frame(width: 60, alignment: .leading)
                Text("").fontWeight(.bold).frame(width: 20)
            }
            .padding(.horizontal, 12)
            Divider()
            List(viewModel.srfs) { srf in
                TrackListItemView(srf: srf, viewModel: viewModel)
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $viewModel.isEditing) {
            MetaEditorView(jsonText: $viewModel.editingJsonText, alertText: $viewModel.editingAlertText) {
                viewModel.save()
            }
        }
    }
    static func MsToMMSS(_ ms: Int) -> String {
        let totalSeconds = ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
