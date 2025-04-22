import AVFoundation
import Foundation

struct TrackAssetLoader {
    static func createTrackAsset(url: URL) async throws -> TrackAsset {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        var trackAsset = TrackAsset(
            url: url,
            artist: "",
            title: url.deletingPathExtension().lastPathComponent,
            album: "",
            duration: Int(CMTimeGetSeconds(duration) * 1000)
        )
        let commonMedataData = try await asset.load(.commonMetadata)
        for item in commonMedataData {
            guard let key = item.commonKey?.rawValue else {
                continue
            }
            do {
                let value = try await item.load(.stringValue)
                switch key {
                case "artist":
                    if let artist = value {
                        trackAsset.artist = artist
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
