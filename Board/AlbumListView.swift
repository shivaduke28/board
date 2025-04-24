import SwiftUI
import SwiftUICore

struct AlbumListView: View {
    @ObservedObject var srfLibrary: SrfLibrary

    var body: some View {
        VStack {
            HStack {
                Text("Album").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            Divider()
            List {
                ForEach(srfLibrary.albums.sorted(by: {$0.value.metadata.title < $1.value.metadata.title}), id: \.value.id) { _, album in
                    HStack {
                        Button(album.metadata.title) {}
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
