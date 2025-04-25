import AVFoundation

struct TrackAsset {
    var url: URL
    let artist: String?
    let title: String?
    let album: String?
    let duration: TimeInterval
    let albumArtist: String?
    let year: Int?
    let trackNumber: Int?
}
