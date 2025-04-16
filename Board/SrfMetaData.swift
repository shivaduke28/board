import Foundation

struct SrfMetaData: Codable, Identifiable {
    var id = UUID()
    let title: String
    let artists: [String]
    let album: String
}
