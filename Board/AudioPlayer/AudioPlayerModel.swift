import AVFAudio
import Foundation
import SwiftUICore

class AudioPlayerModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var srfObject: Srf?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var album: String = ""
    @Published var volume: Float = 1

    private var timer: Timer?

    func load(_ srf: Srf) {
        srfObject = srf
        audioPlayer?.stop()
        let url = srf.url.appendingPathComponent(srf.assetFileName)
        audioPlayer = try? .init(contentsOf: url)
        duration = srf.metadata.duration
        title = srf.metadata.title
        artist = srf.metadata.artist
        album = srf.album.metadata.title
        audioPlayer?.volume = volume
        currentTime = 0
    }

    func play() {
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.stop()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
    }

    func seek(_ time: TimeInterval) {
        print("seek ", time)
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func setVolume(_ volume: Float) {
        self.volume = volume
        audioPlayer?.volume = volume
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }
}
