import AVFoundation

class AudioPlayerController: ObservableObject {
    private let player: AudioPlayerModel

    init(player: AudioPlayerModel) {
        self.player = player
    }

    func load(srf: Srf) {
        player.load(srf: srf)
    }
}
