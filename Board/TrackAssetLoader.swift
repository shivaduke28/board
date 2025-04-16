import AVFoundation
import Foundation

struct TrackAssetLoader {
    static func createTrackAsset(url: URL) async throws -> TrackAsset {
        let asset = AVURLAsset(url: url)
        var trackAsset = TrackAsset(
            url: url,
            artists: [],
            title: url.deletingPathExtension().lastPathComponent,
            album: ""
        )
        let commonMedataData = try await asset.load(.commonMetadata)
        for item in commonMedataData {
            guard let key = item.commonKey?.rawValue else {
                continue
            }
            do {
                let value = try await item.load(.stringValue)
                if let v = value {
                    print(key, v)
                }
                switch key {
                case "artist":
                    if let artist = value {
                        trackAsset.artists.append(artist)
                    }
                case "title":
                    if let title = value {
                        trackAsset.title = title
                    }

                case "albumName":
                    if let albumName = value {
                        trackAsset.album = albumName
                    }
                default:
                    break
                }
            } catch {
                print(
                    "メタデータ取得エラー: \(error.localizedDescription)"
                )
            }
        }

        return trackAsset
    }
}