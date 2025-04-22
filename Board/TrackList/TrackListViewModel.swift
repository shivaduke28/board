import Combine
import SwiftUI

class TrackListViewModel: ObservableObject {
    private let audioPlayer: AudioPlayerViewModel
    private let srfLibrary: SrfLibrary
    @Published var isEditing = false
    @Published var editingMetaUrl: URL?
    @Published var editingJsonText: String = ""
    @Published var editingAlertText: String = ""

    private var cancellables = Set<AnyCancellable>()

    @Published var srfs: [SrfObject] = []

    init(player: AudioPlayerViewModel, srfLibrary: SrfLibrary) {
        self.audioPlayer = player
        self.srfLibrary = srfLibrary

        srfLibrary.$srfs
            .receive(on: DispatchQueue.main)
            .assign(to: \.srfs, on: self)
            .store(in: &cancellables)
    }

    func load(_ srf: SrfObject) {
        audioPlayer.load(srf)
        audioPlayer.play()
    }

    func edit(_ srf: SrfObject) {
        let url = srf.url.appendingPathComponent("meta.json")
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
