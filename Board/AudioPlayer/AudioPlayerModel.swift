import AVFAudio
import Foundation
import SwiftUICore

class AudioPlayerModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var srfObject: SrfObject?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var album: String = ""

    private var timer: Timer?

    func load(_ srf: SrfObject) {
        print("load \(srf.meta.title)")
        srfObject = srf
        audioPlayer?.stop()
        let url = srf.url.appendingPathComponent(srf.meta.fileName)
        audioPlayer = try? .init(contentsOf: url)
        duration = Double(srf.meta.duration) / 1000
        title = srf.meta.title
        artist = srf.meta.artist
        album = srf.meta.album
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
    }

    func seek(_ time: TimeInterval) {
        print("seek ", time)
        audioPlayer?.currentTime = time
        currentTime = time
    }
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }
}
