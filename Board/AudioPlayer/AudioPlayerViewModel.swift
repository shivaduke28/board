import AVFAudio
import Foundation
import SwiftUICore

class AudioPlayerViewModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var srfObject: SrfObject?
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1

    private var timer: Timer?

    func load(_ srf: SrfObject) {
        srfObject = srf
        audioPlayer?.stop()
        let url = srf.url.appendingPathComponent(srf.meta.fileName)
        audioPlayer = try? .init(contentsOf: url)
        duration = Double(srf.meta.duration) / 1000
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

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }
}
