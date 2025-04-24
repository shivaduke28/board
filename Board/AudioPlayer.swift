import AVFoundation
import AppKit

class AudioPlayer: NSObject {
    private var player: AVAudioPlayer?

    func playSound() {
        let music_data=NSDataAsset(name: "kiss")!.data
            do {
                player=try AVAudioPlayer(data:music_data)  
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("再生エラー: \(error.localizedDescription)")
            }
    }

    func stop() {
        player?.stop()
    }
}
