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
                Text(AudioPlayerView.SecToMMSS(audioPlayer.currentTime))
            } maximumValueLabel: {
                Text(AudioPlayerView.SecToMMSS(audioPlayer.duration))
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

    private static func SecToMMSS(_ sec: Double) -> String {
        let minutes = Int(sec / 60)
        let seconds = Int(sec) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let viewModel = AudioPlayerModel()
    let srfObject = SrfObject(
        meta: .init(
            title: "Long Long Title aaaaaaaaaaaaaaaaa",
            artist: "Long Long Artist Nameeeeeaaaaaaaaaaaae",
            artists: ["Test Artist"],
            album: "Test Album",
            remixers: [],
            duration: 321 * 1000,
            fileName: "foo.mp3"
        ),
        url: URL(string: "https://example.com/audio.mp3")!
    )
    viewModel.load(srfObject)
    return AudioPlayerView().environmentObject(viewModel)
}
