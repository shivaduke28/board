import Foundation

struct SrfObject: Identifiable, Equatable {
    static func ==(lhs: SrfObject, rhs: SrfObject) -> Bool {
        lhs.id == rhs.id
    }

    var id: UUID { meta.id }
    let meta: SrfMetaData
    var url: URL
}

struct SrfMetaData: Codable, Identifiable {
    var id = UUID()
    let title: String
    let artist: String
    let artists: [String]
    let album: String
    let remixers: [String]
    let duration: Int
    let fileName: String
}
