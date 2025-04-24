import Foundation

extension TimeInterval {
    var mmss: String {
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int(self / 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
