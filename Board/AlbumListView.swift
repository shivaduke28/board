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
                ForEach(srfLibrary.albums, id: \.self) { album in
                    HStack {
                        Button(album) {}
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
