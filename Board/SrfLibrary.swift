import Foundation

class SrfLibrary: ObservableObject {
    @Published var srfMetaDatas: [SrfMetaData] = []

    let rootDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("BoardLibrary")

    func loadLibrary() {
        var foundMeta: [SrfMetaData] = []
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
                        foundMeta.append(meta)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.srfMetaDatas = foundMeta
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
            let jsonData = try encoder.encode(meta)
            let metaURL = srfDir.appendingPathComponent("meta.json")
            try jsonData.write(to: metaURL)
            print(metaURL.path)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    static func createSrfMetaData(asset: TrackAsset) -> SrfMetaData {
        SrfMetaData(
            title: asset.title,
            artists: asset.artists,
            album: asset.album
        )
    }
}
