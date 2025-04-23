//
//  BoardApp.swift
//  Board
//
//  Created by Kei Hasegawa on 2025/04/16.
//

import SwiftUI

@main
struct BoardApp: App {
    var body: some Scene {
        let audioPlayerModel = AudioPlayerModel()
        WindowGroup {
            ContentView(viewModel: .init(audioPlayer: audioPlayerModel))
                .environmentObject(audioPlayerModel)
        }
    }
}
