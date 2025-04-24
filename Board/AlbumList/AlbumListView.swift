import SwiftUI
import SwiftUICore

struct AlbumListView: View {
    @ObservedObject var srfLibrary: SrfLibrary

    var body: some View {
        VStack {
            HStack {
                Text("Album").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Text("Artist").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Text("Artists").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Text("Year").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .padding(.horizontal, 12)
            Divider()
            List {
                ForEach(
                    srfLibrary.albums.sorted(by: {
                        $0.value.metadata.title < $1.value.metadata.title
                    }),
                    id: \.value.id
                ) { _, album in
                    HStack {
                        Text(album.metadata.title).frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        Text(album.metadata.artist).frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        HStack {
                            ForEach(album.metadata.artists, id: \.self) {
                                artist in
                                Button(artist) {}
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Text(toString(album.metadata.year)).frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    func toString(_ num: Int?) -> String {
        num.map(String.init) ?? ""
    }
}
