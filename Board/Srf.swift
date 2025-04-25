import Foundation

struct Srf: Identifiable, Equatable {
    static func == (lhs: Srf, rhs: Srf) -> Bool {
        lhs.id == rhs.id
    }

    var id = SrfId()
    let metadata: SrfMetadata
    let album: Album
    let url: URL
    let assetFileName: String
}

typealias SrfId = UUID
struct SrfMetadata: Codable {
    let title: String
    let artist: String
    let artists: [String]
    let remixers: [String]
    let duration: TimeInterval
    let trackNumber: Int?
}

typealias AlbumId = UUID

struct Album: Identifiable {
    var id = AlbumId()
    let metadata: AlbumMetadata
    let url: URL
}

struct AlbumMetadata: Codable {
    let title: String
    let artist: String
    let artists: [String]
    let year: Int?

    func directoryName() -> String {
        "\(artist) - \(title)"
    }
}
