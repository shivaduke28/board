import SwiftUI

@main
struct BoardApp: App {
    var body: some Scene {
        let audioPlayerModel = AudioPlayerModel()
        let srfLibrary = SrfLibrary()
        let trackAssetImporter = TrackAssetImporter(srfLibrary: srfLibrary)
        let srfMetadataEditor = SrfMetadataEditor(srfLibrary: srfLibrary)
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayerModel)
                .environmentObject(srfLibrary)
                .environmentObject(trackAssetImporter)
                .environmentObject(srfMetadataEditor)
        }
    }
}
