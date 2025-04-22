import AVFoundation
import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var viewModel: AudioPlayerViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.srfObject?.meta.title ?? "")
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.headline)
                Text(viewModel.srfObject?.meta.artist ?? "").font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.frame(width: 180)
                .padding(.horizontal)
            HStack {
                Button("stop", systemImage: "stop.fill") { viewModel.stop() }
                    .labelStyle(.iconOnly)
                Button("play", systemImage: "play.fill") { viewModel.play() }
                    .labelStyle(.iconOnly)
                Button("pause", systemImage: "pause.fill") { viewModel.pause() }
                    .labelStyle(.iconOnly)
            }.padding(.horizontal)
            HStack {
                Text(AudioPlayerView.SecToMMSS(viewModel.currentTime))
                    .frame(width: 60)
                Slider(value: $viewModel.currentTime, in: 0...viewModel.duration)
                    .padding(.horizontal)
                    .frame(width: 120)
                Text(AudioPlayerView.SecToMMSS(viewModel.duration))
                    .frame(width: 60)
            }.frame(width: 200)
                .padding(.horizontal)
        }.onAppear {
            viewModel.startTimer()
        }
    }

    private static func SecToMMSS(_ sec: Double) -> String {
        let minutes = Int(sec / 60)
        let seconds = Int(sec) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let viewModel = AudioPlayerViewModel()
    let srfObject = SrfObject(
        meta: .init(
            title: "Long Long Title aaaaaaaaaaaaaaaaa",
            artist: "Long Long Artist Nameeeeeaaaaaaaaaaaae",
            artists: ["Test Artist"],
            album: "Test Album",
            remixers: [],
            duration: 321 * 1000,
            fileName: "foo.mp3"
        ), url: URL(string: "https://example.com/audio.mp3")!)
    viewModel.load(srfObject)
    return AudioPlayerView(viewModel: viewModel)
}
