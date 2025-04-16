import AVFoundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct TrackMetadata: CustomStringConvertible {
    var path: String
    var artists: [String]
    var title: String
    var albumName: String
    var description: String {
        return """
            TrackMetadata(
              path: \(path),
              artists: \(artists),
              title: \(title),
              albumName: \(albumName)
            )
            """
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("mp3ファイルを選択") {
                selectAndReadMP3()
            }
        }
        .frame(width: 300, height: 200)
    }

    func selectAndReadMP3() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { result in

            if result == .OK, let url = panel.url {
                Task {
                    do {
                        let asset = AVURLAsset(url: url)
                        var trackMetadata = TrackMetadata(
                            path: url.path,
                            artists: [],
                            title: "",
                            albumName: ""
                        )
                        let commonMedataData = try await asset.load(
                            .commonMetadata
                        )
                        for item in commonMedataData {
                            guard let key = item.commonKey?.rawValue else {
                                continue
                            }
                            do {
                                let value = try await item.load(.stringValue)
                                switch key {
                                case "artist":
                                    if let artist = value {
                                        trackMetadata.artists.append(artist)
                                    }
                                case "title":
                                    if let title = value {
                                        trackMetadata.title = title
                                    }
                                case "albumName":
                                    if let albumName = value {
                                        trackMetadata.albumName = albumName
                                    }
                                default:
                                    break
                                }
                            } catch {
                                print("メタデータ取得エラー: \(error.localizedDescription)")
                            }
                        }
                        print(trackMetadata.description)
                    } catch {
                        print("エラー: \(error.localizedDescription)")
                    }

                }
            }
        }
    }
}
