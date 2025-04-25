extension Int? {
    var toText: String {
        guard let self = self else { return "" }
        return String(self)
    }
}
