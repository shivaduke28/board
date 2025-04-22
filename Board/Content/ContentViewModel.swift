import AppKit
import Foundation
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {

    let srfLibrary = SrfLibrary()
    let trackList: TrackListViewModel
    let audioPlayer = AudioPlayerViewModel()

    init() {
        trackList = .init(player: audioPlayer, srfLibrary: srfLibrary)
    }

    @Published var selectedSideBarItem: SidebarItem = .tracks

    func selectAndImportMP3() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.begin { result in
            guard result == .OK else { return }
            let mp3Urls = panel.urls.flatMap { url -> [URL] in
                if url.hasDirectoryPath {
                    return FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)?
                        .compactMap { $0 as? URL }
                        .filter { $0.pathExtension.lowercased() == "mp3" } ?? []
                } else {
                    return [url]
                }
            }
            Task {
                await self.srfLibrary.importMP3Files(mp3Urls)
            }
        }
    }

    func loadLibrary() {
        srfLibrary.loadLibrary()
    }
}
