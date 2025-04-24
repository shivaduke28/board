import SwiftUI
import SwiftUICore

struct ArtistListView: View {
    @ObservedObject var srfLibrary: SrfLibrary

    var body: some View {
        VStack {
            HStack {
                Text("Artist").fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            Divider()
            List {
                ForEach(Array(srfLibrary.artists), id: \.self) { artist in
                    HStack {
                        Button(artist) {}
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
