import Foundation

class SrfLibrary: ObservableObject {
    @Published var srfs: [SrfId: Srf] = [:]
    @Published var albums: [AlbumId: Album] = [:]
    @Published var artists: Set<String> = []

    static let albumFileExtension: String = "srfa"
    static let srfFileExtension: String = "srf"
    static let albumMetaFileName = "srfa.json"
    static let srfMetaFileName = "srf.json"

    let emptyAlbumName = "Unknown"
    let emptyArtistName = "Unknown"
    let rootUrl: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("BoardLibrary")

    func loadLibrary() {
        var newSrfs: [SrfId: Srf] = [:]
        var newAlbums: [AlbumId: Album] = [:]
        do {
            // rootの下にアルバムが入っている前提
            let urls = try FileManager.default.contentsOfDirectory(
                at: rootUrl,
                includingPropertiesForKeys: nil
            )
            for url in urls {
                if url.pathExtension == SrfLibrary.albumFileExtension {
                    loadAlbum(url: url, albums: &newAlbums, srfs: &newSrfs)
                }
            }
        } catch {
            print("Load failed: ", error.localizedDescription)
        }

        DispatchQueue.main.async {
            self.albums = newAlbums
            self.srfs = newSrfs
        }
    }

    /// TODO: catchをもう少し丁寧に
    func loadAlbum(
        url: URL,
        albums: inout [AlbumId: Album],
        srfs: inout [SrfId: Srf]
    ) {
        do {
            let albumMetaUrl = url.appendingPathComponent(
                SrfLibrary.albumMetaFileName
            )
            let data = try Data(contentsOf: albumMetaUrl)
            let albumMeta = try JSONDecoder().decode(
                AlbumMetadata.self,
                from: data
            )
            let album = Album(metadata: albumMeta, url: url)
            albums[album.id] = album
            artists.formUnion(albumMeta.artists)

            // albumディレクトリに直下に.srfが入っている前提
            let srfUrls = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil
            )
            for srfUrl in srfUrls {
                guard srfUrl.pathExtension == SrfLibrary.srfFileExtension else {
                    continue
                }
                let srfMetaUrl = srfUrl.appendingPathComponent(
                    SrfLibrary.srfMetaFileName
                )
                let data = try Data(contentsOf: srfMetaUrl)
                let srfMeta = try JSONDecoder().decode(
                    SrfMetadata.self,
                    from: data
                )
                let assetFileName = try getAssetFileName(srfUrl: srfUrl)
                let srf = Srf(
                    metadata: srfMeta,
                    album: album,
                    url: srfUrl,
                    assetFileName: assetFileName
                )
                srfs[srf.id] = srf
                artists.formUnion(srfMeta.artists)
                artists.formUnion(srfMeta.remixers)
            }
        } catch {
            print("Load album failed:", error.localizedDescription)
        }
    }

    func getAssetFileName(srfUrl: URL) throws -> String {
        try FileManager.default.contentsOfDirectory(
            at: srfUrl,
            includingPropertiesForKeys: []
        ).first(where: { $0.pathExtension == "mp3" })!
        .lastPathComponent
    }

    func importMP3Files(_ urls: [URL]) async {
        for url in urls {
            do {
                let trackAsset = try await TrackAsset.createFromMp3(url: url)
                try createSrf(trackAsset)
            } catch {
                print(url.lastPathComponent)
                print(error.localizedDescription)
            }
        }
        loadLibrary()
    }

    private func getOrCreateAlbum(asset: TrackAsset) throws -> Album {
        if let album = getAlbum(asset: asset) {
            return album
        } else {
            return try createAlbum(asset: asset)
        }
    }

    private func getAlbum(asset: TrackAsset) -> Album? {
        let albumName = asset.album ?? emptyAlbumName
        let artistName = asset.albumArtist ?? asset.artist ?? emptyArtistName
        return albums.first { (key: AlbumId, value: Album) in
            value.metadata.title == albumName
                && value.metadata.artist == artistName
        }?.value
    }

    private func createAlbum(asset: TrackAsset) throws -> Album {
        let artist = asset.albumArtist ?? asset.artist ?? emptyArtistName
        let albumMeta = AlbumMetadata(
            title: asset.album ?? emptyAlbumName,
            artist: artist,
            artists: [artist],
            year: asset.year
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(albumMeta)
        let albumDirectoryUrl = rootUrl.appendingPathComponent(
            albumMeta.directoryName()
        ).appendingPathExtension(SrfLibrary.albumFileExtension)
        try FileManager.default.createDirectory(
            at: albumDirectoryUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let albumMetaDataUrl = albumDirectoryUrl.appendingPathComponent(
            SrfLibrary.albumMetaFileName
        )
        try jsonData.write(to: albumMetaDataUrl)
        return Album(metadata: albumMeta, url: albumDirectoryUrl)
    }

    private func createSrf(_ asset: TrackAsset) throws {
        let album = try getOrCreateAlbum(asset: asset)
        let fileName = asset.url.deletingPathExtension().lastPathComponent
        let srfUrl =
            album.url.appendingPathComponent("\(fileName).\(SrfLibrary.srfFileExtension)")

        if srfs.first(where: { $0.value.url == srfUrl }) != nil {
            print("Skip existing srf \(srfUrl).")
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: srfUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let destMP3 = srfUrl.appendingPathComponent("\(fileName).mp3")
            if FileManager.default.fileExists(atPath: destMP3.path) {
                try FileManager.default.removeItem(at: destMP3)
            }
            try FileManager.default.copyItem(at: asset.url, to: destMP3)
            let meta = SrfLibrary.createSrfMetaData(
                asset: asset,
                albumId: album.id
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(meta)
            let metaUrl = srfUrl.appendingPathComponent(SrfLibrary.srfMetaFileName)
            try jsonData.write(to: metaUrl)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func updateSrf(metaUrl: URL, json: String) throws {
        guard let jsonData = json.data(using: .utf8) else {
            fatalError("文字列のData変換に失敗しました")
        }

        let meta = try JSONDecoder().decode(SrfMetadata.self, from: jsonData)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(meta)
        try encoded.write(to: metaUrl)
    }

    private static func createSrfMetaData(asset: TrackAsset, albumId: AlbumId)
        -> SrfMetadata
    {
        SrfMetadata(
            title: asset.title ?? asset.url.lastPathComponent,
            artist: asset.artist ?? "",
            artists: extractArtists(asset.artist),
            remixers: extractRemixers(asset.title),
            duration: asset.duration
        )
    }

    // TODO: titleにfeat.が入っているケースがある
    private static func extractArtists(_ artist: String?) -> [String] {
        guard let artist else { return [] }
        let pattern = "\\s*feat\\.\\s*"
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: .caseInsensitive
        )

        let range = NSRange(artist.startIndex..., in: artist)

        if let match = regex.firstMatch(in: artist, options: [], range: range) {
            let matchRange = match.range
            let firstPart = String(
                artist[
                    ..<artist.index(
                        artist.startIndex,
                        offsetBy: matchRange.lowerBound
                    )
                ]
            )
            let secondPart = String(
                artist[
                    artist.index(
                        artist.startIndex,
                        offsetBy: matchRange.upperBound
                    )...
                ]
            )
            return [
                firstPart.trimmingCharacters(in: .whitespaces),
                secondPart.trimmingCharacters(in: .whitespaces),
            ]
        } else {
            return [artist.trimmingCharacters(in: .whitespaces)]
        }
    }

    private static func extractRemixers(_ input: String?) -> [String] {
        guard let input else { return [] }
        let pattern =
            "\\((.*?)\\s+(Remix|Refix|Re-fix|Rework|Bootleg|Boot|Flip)\\)"
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: .caseInsensitive
        )
        let nsrange = NSRange(input.startIndex..., in: input)
        if let match = regex.firstMatch(in: input, options: [], range: nsrange),
            let range = Range(match.range(at: 1), in: input)
        {
            return [String(input[range])]
        }
        return []
    }
}
