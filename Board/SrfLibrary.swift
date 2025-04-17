import Foundation

class SrfLibrary: ObservableObject {
    @Published var srfs: [SrfObject] = []

    let rootDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("BoardLibrary")

    func loadLibrary() {
        var newSrfs: [SrfObject] = []
        if let enumerator = FileManager.default.enumerator(
            at: rootDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in enumerator {
                if url.pathExtension == "srf" {
                    let metaURL = url.appendingPathComponent("meta.json")
                    if FileManager.default.fileExists(atPath: metaURL.path),
                        let data = try? Data(contentsOf: metaURL),
                        let meta = try? JSONDecoder().decode(SrfMetaData.self, from: data)
                    {
                        newSrfs.append(SrfObject(meta: meta, url: url))
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.srfs = newSrfs
        }
    }

    func createSrf(asset: TrackAsset) {
        let fileName = asset.url.deletingPathExtension().lastPathComponent
        var srfDir = rootDir
        srfDir = srfDir.appendingPathComponent(asset.album.isEmpty ? "UnknownAlbum" : asset.album)
        srfDir = srfDir.appendingPathComponent("\(fileName).srf")
        do {
            try FileManager.default.createDirectory(at: srfDir, withIntermediateDirectories: true, attributes: nil)
            let destMP3 = srfDir.appendingPathComponent("\(fileName).mp3")
            if FileManager.default.fileExists(atPath: destMP3.path) {
                try FileManager.default.removeItem(at: destMP3)
            }
            try FileManager.default.copyItem(at: asset.url, to: destMP3)
            let meta = SrfLibrary.createSrfMetaData(asset: asset)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(meta)
            let metaURL = srfDir.appendingPathComponent("meta.json")
            try jsonData.write(to: metaURL)
            print(metaURL.path)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func updateSrf(url: URL, json: String) throws {
        guard let jsonData = json.data(using: .utf8) else {
            fatalError("文字列のData変換に失敗しました")
        }
        // TODO: album名が変わっていたときにパスを変更する必要がある
        let meta = try JSONDecoder().decode(SrfMetaData.self, from: jsonData)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(meta)
        try encoded.write(to: url)
    }

    static func createSrfMetaData(asset: TrackAsset) -> SrfMetaData {
        SrfMetaData(
            title: asset.title,
            artists: asset.artists,
            album: asset.album,
            remixers: []
        )
    }
}
