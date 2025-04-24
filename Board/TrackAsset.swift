import AVFoundation

struct TrackAsset {
    var url: URL
    let artist: String?
    let title: String?
    let album: String?
    let duration: TimeInterval
    let albumArtist: String?
    let year: Int?

    static func createFromMp3(url: URL) async throws -> TrackAsset {
        let asset = AVURLAsset(url: url)
        let duration: TimeInterval = CMTimeGetSeconds(
            try await asset.load(.duration)
        )

        var artist: String? = nil
        var title: String? = nil
        var album: String? = nil
        var albumArtist: String? = nil
        var year: Int? = nil

        // metadataとしては取得できないがcommonMetadataで取得できるケースがあるのでこちらを優先する
        let commonMedadata = try await asset.load(.commonMetadata)
        for item in commonMedadata {
            switch item.commonKey {
            case AVMetadataKey.commonKeyTitle:
                title = try await item.load(.stringValue)
            case AVMetadataKey.commonKeyArtist:
                artist = try await item.load(.stringValue)
            case AVMetadataKey.commonKeyAlbumName:
                album = try await item.load(.stringValue)
            default:
                break
            }
        }

        let id3Metadata = try await asset.loadMetadata(for: .id3Metadata)
        for item in id3Metadata {
            guard let key = item.key as? AVMetadataKey else { continue }
            switch key {
            case AVMetadataKey.id3MetadataKeyBand:
                albumArtist = try await item.load(.stringValue)
            case AVMetadataKey.id3MetadataKeyYear,
                AVMetadataKey.id3MetadataKeyRecordingTime:
                year = try await item.load(.stringValue).flatMap(Int.init)
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
            albumArtist: albumArtist,
            year: year
        )
    }
}
