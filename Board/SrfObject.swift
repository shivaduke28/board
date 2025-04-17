import Foundation

struct SrfObject: Identifiable {
    var id: UUID { meta.id }
    let meta: SrfMetaData
    var url: URL
}

struct SrfMetaData: Codable, Identifiable {
    var id = UUID()
    let title: String
    let artists: [String]
    let album: String
    let remixers: [String]
}
