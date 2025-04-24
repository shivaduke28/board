import Combine
import SwiftUI

class TrackListViewModel: ObservableObject {
    private let audioPlayer: AudioPlayerModel
    private let srfLibrary: SrfLibrary
    @Published var isEditing = false
    @Published var editingMetaUrl: URL?
    @Published var editingJsonText: String = ""
    @Published var editingAlertText: String = ""

    private var cancellables = Set<AnyCancellable>()

    @Published var srfs: [Srf] = []

    init(audioPlayer: AudioPlayerModel, srfLibrary: SrfLibrary) {
        self.audioPlayer = audioPlayer
        self.srfLibrary = srfLibrary

        srfLibrary.$srfs
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { self.srfs = Array($0.values) })
            .store(in: &cancellables)
    }

    func load(_ srf: Srf) {
        audioPlayer.load(srf)
        audioPlayer.play()
    }

    func edit(_ srf: Srf) {
        let url = srf.url.appendingPathComponent(SrfLibrary.srfMetaFileName)
        editingMetaUrl = url
        editingJsonText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        isEditing = true
    }

    func save() {
        do {
            if let url = editingMetaUrl {
                try srfLibrary.updateSrf(metaUrl: url, json: editingJsonText)
                isEditing = false
                srfLibrary.loadLibrary()
            }
        } catch {
            print(error.localizedDescription)
            editingAlertText = "Save failed."
        }
    }
}
