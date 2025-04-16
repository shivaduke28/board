import AVFoundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct TrackAsset {
    var url: URL
    var artists: [String]
    var title: String
    var album: String
}

struct SrfMetaData: Codable, Identifiable {
    var id = UUID()
    let title: String
    let artists: [String]
    let album: String
}

struct ContentView: View {
    @State private var srfMetaDatas: [SrfMetaData] = []
    @State private var selectedMetaID: UUID? = nil
    var body: some View {
        VStack {
            Button("Import mp3") {
                selectAndImportMP3()
            }
            HStack {
                Text("title").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Text("artists").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Text("album").fontWeight(.bold).frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            Divider()
            List(selection: $selectedMetaID) {
                ForEach(srfMetaDatas) { meta in
                    HStack {
                        Text(meta.title).frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        Text(meta.artists.joined(separator: ", ")).frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        Text(meta.album).frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.plain)

        }
        .onAppear(perform: loadLibrary)
    }

    func loadLibrary() {
        let rootURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("BoardLibrary")
        var foundMeta: [SrfMetaData] = []
        if let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in enumerator {
                if url.pathExtension == "srf" {
                    let metaURL = url.appendingPathComponent("meta.json")
                    if FileManager.default.fileExists(atPath: metaURL.path) {
                        if let data = try? Data(contentsOf: metaURL),
                            let meta = try? JSONDecoder().decode(
                                SrfMetaData.self,
                                from: data
                            )
                        {
                            foundMeta.append(meta)
                        }
                    }
                }
            }
        }
        srfMetaDatas = foundMeta
    }

    func createTrackAsset(url: URL) async throws -> TrackAsset {
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

    func createSrfMetaData(asset: TrackAsset) -> SrfMetaData {
        SrfMetaData(
            title: asset.title,
            artists: asset.artists,
            album: asset.album
        )
    }

    func createSrf(asset: TrackAsset) {
        let fileName = asset.url.deletingPathExtension().lastPathComponent
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let boardDir = homeDir.appendingPathComponent("BoardLibrary")
        var srfDir = boardDir

        if !asset.album.isEmpty {
            srfDir = srfDir.appendingPathComponent(asset.album)
        } else {
            srfDir = srfDir.appendingPathComponent("UnknownAlbum")
        }

        srfDir = srfDir.appendingPathComponent("\(fileName).srf")
        do {
            try FileManager.default.createDirectory(
                at: srfDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let destMP3 = srfDir.appendingPathComponent("\(fileName).mp3")
            if FileManager.default.fileExists(atPath: destMP3.path) {
                try FileManager.default.removeItem(at: destMP3)
            }
            try FileManager.default.copyItem(at: asset.url, to: destMP3)

            let meta = createSrfMetaData(asset: asset)
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(meta)
            let json = String(data: jsonData, encoding: .utf8)!
            let metaURL = srfDir.appendingPathComponent("meta.json")
            try json.write(to: metaURL, atomically: true, encoding: .utf8)
            print(metaURL.path)
            print(json)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func selectAndImportMP3() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { result in
            if result == .OK, let url = panel.url {
                Task {
                    do {
                        let trackAsset = try await createTrackAsset(url: url)
                        createSrf(asset: trackAsset)
                        loadLibrary()
                    } catch {
                        print("エラー: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
