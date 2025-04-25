import SwiftUI

@main
struct BoardApp: App {
    var body: some Scene {
        let audioPlayerModel = AudioPlayerModel()
        let audioPlayerController = AudioPlayerController(player: audioPlayerModel)
        let srfLibrary = SrfLibrary()
        let trackAssetImporter = TrackAssetImporter(srfLibrary: srfLibrary)
        let srfMetadataEditor = SrfMetadataEditor(srfLibrary: srfLibrary)
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayerModel)
                .environmentObject(audioPlayerController)
                .environmentObject(srfLibrary)
                .environmentObject(trackAssetImporter)
                .environmentObject(srfMetadataEditor)
        }
    }
}
