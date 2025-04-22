import Foundation

class SrfLibrary: ObservableObject {
    @Published var srfs: [SrfObject] = []
    private var artistSet: Set<String> = []
    var artists: [String] = []

    private var albumSet: Set<String> = []
    var albums: [String] = []

    let rootUrl: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("BoardLibrary")
    let metaFileName = "meta.json"

    func loadLibrary() {
        var newSrfs: [SrfObject] = []
        artistSet.removeAll()
        albumSet.removeAll()
        if let enumerator = FileManager.default.enumerator(
            at: rootUrl,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in enumerator {
                if url.pathExtension == "srf" {
                    let metaUrl = url.appendingPathComponent(metaFileName)
                    if FileManager.default.fileExists(atPath: metaUrl.path),
                        let data = try? Data(contentsOf: metaUrl),
                        let meta = try? JSONDecoder().decode(SrfMetaData.self, from: data)
                    {
                        newSrfs.append(SrfObject(meta: meta, url: url))
                        artistSet.formUnion(meta.artists)
                        artistSet.formUnion(meta.remixers)
                        albumSet.insert(meta.album)
                    }
                }
            }
        }
        artists = Array(artistSet).sorted()
        albums = Array(albumSet).sorted()
        DispatchQueue.main.async {
            self.srfs = newSrfs
        }
    }

    func importMP3Files(_ urls: [URL]) async {
        for url in urls {
            if let trackAsset = try? await TrackAssetLoader.createTrackAsset(url: url) {
                createSrf(asset: trackAsset)
            }
        }
        loadLibrary()
    }

    private func createSrf(asset: TrackAsset) {
        let fileName = asset.url.deletingPathExtension().lastPathComponent
        let srfUrl =
            rootUrl
            .appendingPathComponent(asset.album.isEmpty ? "UnknownAlbum" : asset.album)
            .appendingPathComponent("\(fileName).srf")

        if srfs.first(where: { $0.url == srfUrl }) != nil {
            print("Skip existing srf \(srfUrl).")
            return
        }

        do {
            try FileManager.default.createDirectory(at: srfUrl, withIntermediateDirectories: true, attributes: nil)
            let destMP3 = srfUrl.appendingPathComponent("\(fileName).mp3")
            if FileManager.default.fileExists(atPath: destMP3.path) {
                try FileManager.default.removeItem(at: destMP3)
            }
            try FileManager.default.copyItem(at: asset.url, to: destMP3)
            let meta = SrfLibrary.createSrfMetaData(asset: asset)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(meta)
            let metaUrl = srfUrl.appendingPathComponent(metaFileName)
            try jsonData.write(to: metaUrl)
            print(metaUrl.path)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func updateSrf(metaUrl: URL, json: String) throws {
        guard let jsonData = json.data(using: .utf8) else {
            fatalError("文字列のData変換に失敗しました")
        }

        let fileManager = FileManager.default
        let meta = try JSONDecoder().decode(SrfMetaData.self, from: jsonData)
        let srfUrl = metaUrl.deletingLastPathComponent()
        let originalSrf = srfs.first(where: { $0.url == srfUrl })!

        var dstMetaUrl = metaUrl
        if originalSrf.meta.album != meta.album {
            let srfFileName = srfUrl.lastPathComponent
            let originalAlbumUrl = srfUrl.deletingLastPathComponent()
            let newAlbumUrl = originalAlbumUrl.deletingLastPathComponent()
                .appendingPathComponent(meta.album)
            let newSrfUrl = newAlbumUrl.appendingPathComponent(srfFileName)
            try fileManager.createDirectory(at: newAlbumUrl, withIntermediateDirectories: true)
            try fileManager.moveItem(at: srfUrl, to: newSrfUrl)
            if try fileManager.contentsOfDirectory(at: originalAlbumUrl, includingPropertiesForKeys: nil).isEmpty {
                try fileManager.removeItem(at: originalAlbumUrl)
            }
            dstMetaUrl = newSrfUrl.appendingPathComponent(metaFileName)

            // callerがloadを呼ぶので不要だが一応やってる
            DispatchQueue.main.async {
                self.srfs.removeAll(where: { $0.url == originalSrf.url })
                let newSrf = SrfObject(meta: meta, url: newSrfUrl)
                self.srfs.append(newSrf)
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(meta)
        try encoded.write(to: dstMetaUrl)
    }

    private static func createSrfMetaData(asset: TrackAsset) -> SrfMetaData {
        SrfMetaData(
            title: asset.title,
            artist: asset.artist,
            artists: extractArtists(asset.artist),
            album: asset.album,
            remixers: extractRemixers(asset.title),
            duration: asset.duration
        )
    }

    // TODO: titleにfeat.が入っているケースがある
    private static func extractArtists(_ artist: String) -> [String] {
        let pattern = "\\s*feat\\.\\s*"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        let range = NSRange(artist.startIndex..., in: artist)

        if let match = regex.firstMatch(in: artist, options: [], range: range) {
            let matchRange = match.range
            let firstPart = String(artist[..<artist.index(artist.startIndex, offsetBy: matchRange.lowerBound)])
            let secondPart = String(artist[artist.index(artist.startIndex, offsetBy: matchRange.upperBound)...])
            return [firstPart.trimmingCharacters(in: .whitespaces), secondPart.trimmingCharacters(in: .whitespaces)]
        } else {
            return [artist.trimmingCharacters(in: .whitespaces)]
        }
    }

    private static func extractRemixers(_ input: String) -> [String] {
        let pattern = "\\((.*?)\\s+(Remix|Refix|Re-fix|Rework|Bootleg|Boot|Flip)\\)"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsrange = NSRange(input.startIndex..., in: input)
        if let match = regex.firstMatch(in: input, options: [], range: nsrange),
            let range = Range(match.range(at: 1), in: input)
        {
            return [String(input[range])]
        }
        return []
    }
}
