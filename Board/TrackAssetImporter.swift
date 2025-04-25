import AVFoundation
import AppKit
import Foundation
import UniformTypeIdentifiers

class TrackAssetImporter: ObservableObject {
    let srfLibrary: SrfLibrary

    init(srfLibrary: SrfLibrary) {
        self.srfLibrary = srfLibrary
    }

    func selectAndImportMP3() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.begin { result in
            guard result == .OK else { return }
            let mp3Urls = panel.urls.flatMap { url -> [URL] in
                if url.hasDirectoryPath {
                    return FileManager.default.enumerator(
                        at: url,
                        includingPropertiesForKeys: nil
                    )?
                    .compactMap { $0 as? URL }
                    .filter { $0.pathExtension.lowercased() == "mp3" } ?? []
                } else {
                    return [url]
                }
            }
            Task {
                for url in mp3Urls {
                    if let trackAsset =
                        try? await TrackAssetImporter.createFromMp3(url: url)
                    {
                        await self.srfLibrary.importTrackAsset(trackAsset)
                    }
                }
                self.srfLibrary.loadLibrary()
            }
        }
    }

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
        var trackNumber: Int? = nil

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
            case AVMetadataKey.id3MetadataKeyTrackNumber:
                let stringValue = try await item.load(.stringValue)
                trackNumber = extractLeadingNumberAsInt(stringValue)
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
            year: year,
            trackNumber: trackNumber
        )
    }

    static func extractLeadingNumberAsInt(_ input: String?) -> Int? {
        guard let input = input else { return nil }
        guard let match = input.firstMatch(of: /^(\d+)/) else { return nil }
        return Int(String(match.1))
    }
}
