import AVFoundation
import SwiftUI

struct PlayerView: View {
    @State private var player: AVAudioPlayer?
    @Binding var selectedSrfObject: SrfObject?

    var body: some View {
        HStack {
            Button("Play") {
                play()
            }.padding()
            Button("Stop") {
                stop()
            }.padding()
            Text(selectedSrfObject?.meta.title ?? "")
        }.onChange(of: selectedSrfObject) {
            onChangeSelected()
        }
    }

    func onChangeSelected() {
        player?.stop()
        player = nil

        if let srf = selectedSrfObject {
            let fileUrl = srf.url.appendingPathComponent(srf.meta.fileName)
            player = try? AVAudioPlayer(contentsOf: fileUrl)
        }
    }

    func play() {
        player?.play()
    }

    func stop() {
        player?.stop()
    }
}
