import SwiftUI

struct AudioPlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(audioPlayer.title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.headline)
                Text(audioPlayer.artist).font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.frame(width: 180)
                .padding(.horizontal)
            HStack {
                Button("stop", systemImage: "stop.fill") { audioPlayer.stop() }
                    .labelStyle(.iconOnly)
                Button("play", systemImage: "play.fill") { audioPlayer.play() }
                    .labelStyle(.iconOnly)
                Button("pause", systemImage: "pause.fill") {
                    audioPlayer.pause()
                }
                .labelStyle(.iconOnly)
            }.padding(.horizontal)
            Slider(
                value: $audioPlayer.currentTime,
                in: 0...audioPlayer.duration
            ) {
            } minimumValueLabel: {
                Text(audioPlayer.currentTime.mmss)
            } maximumValueLabel: {
                Text(audioPlayer.duration.mmss)
            } onEditingChanged: { editing in
                if !editing {
                    audioPlayer.seek(audioPlayer.currentTime)
                }
            }
            .frame(width: 200)
            .padding(.horizontal)
            Slider(
                value: $audioPlayer.volume,
                in: 0...1,
                onEditingChanged: { editing in
                    if !editing {
                        audioPlayer.setVolume(audioPlayer.volume)
                    }
                },
                minimumValueLabel: Image(systemName: "speaker.fill"),
                maximumValueLabel: Image(systemName: "speaker.wave.3.fill"),
                label: { EmptyView() },
            ).frame(width: 100).padding(.horizontal)
        }.onAppear {
            audioPlayer.startTimer()
        }
    }
}

#Preview {
    let viewModel = AudioPlayerModel()
    let srfMeta = SrfMetadata(
        title: "long long title",
        artist: "long long artist name",
        artists: ["Test Artist"],
        remixers: ["Test remixer"],
        duration: 100,
        trackNumber: 5,
    )
    let srfObject = Srf(
        metadata: srfMeta,
        album: Album(
            metadata: .init(
                title: "title",
                artist: "artist",
                artists: ["artist"],
                year: 1990
            ),
            url: URL(string: "foo")!
        ),
        url: URL(string: "https://example.com/audio.mp3")!,
        assetFileName: "audio.mp3"
    )
    viewModel.load(srf: srfObject)
    return AudioPlayerView().environmentObject(viewModel)
}
