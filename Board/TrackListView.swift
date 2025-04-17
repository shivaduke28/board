import SwiftUI

struct TrackListView: View {
    @ObservedObject var srfLibrary: SrfLibrary
    @State private var selectedMetaID: UUID? = nil
    @State private var isEditing = false
    @State private var editingMetaUrl: URL?
    @State private var editingJsonText: String = ""
    @State private var editingAlertText: String = ""


    var body: some View {
        VStack {
            HStack {
                Text("Title").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Artist").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Artists").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Album").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Remixers").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            Divider()
            List(selection: $selectedMetaID) {
                ForEach(srfLibrary.srfs) { srf in
                    let meta = srf.meta
                    HStack {
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
                        Button(
                            "Edit",
                            action: {
                                let url = srf.url.appendingPathComponent("meta.json")
                                editingMetaUrl = url
                                editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                                isEditing = true
                            }
                        )
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $isEditing) {
            MetaEditorView(jsonText: $editingJsonText, alertText: $editingAlertText) {
                do {
                    if let url = editingMetaUrl {
                        try srfLibrary.updateSrf(metaUrl: url, json: editingJsonText)
                        isEditing = false
                        srfLibrary.loadLibrary()
                    }
                } catch {
                    print(error.localizedDescription)
                    editingAlertText = "Save failed."
                }
            }
        }
    }
}
