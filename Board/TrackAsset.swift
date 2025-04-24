import AVFoundation

struct TrackAsset {
    var url: URL
    let artist: String?
    let title: String?
    let album: String?
    let duration: TimeInterval
    let albumArtist: String?

    static func createFromMp3(url: URL) async throws -> TrackAsset {
        let asset = AVURLAsset(url: url)
        let duration: TimeInterval = CMTimeGetSeconds(
            try await asset.load(.duration)
        )

        print("----\(url.lastPathComponent)----")

        var artist: String? = nil
        var title: String? = nil
        var album: String? = nil
        var albumArtist: String? = nil

        for item in asset.commonMetadata {
            print(item.keySpace, item.identifier ?? "", item.commonKey ?? "", item.key ?? "",  item.value ?? "")
        }

        print("--id3")

        let id3Metadata = try await asset.loadMetadata(for: .id3Metadata)
        for item in id3Metadata {
            guard let key = item.key as? String else { continue }
            guard let value = try await item.load(.stringValue) else {
                continue
            }
            print(key, value)
            switch key {
            case "TIT2":
                title = value
            case "TPE1":
                artist = value
            case "TPE2":
                albumArtist = value
            case "TALB":
                album = value
            default:
                break
            }
        }

        return TrackAsset(
            url: url,
            artist: artist,
            title: title,
            album: album,
            duration: duration,
            albumArtist: albumArtist
        )
    }
}
