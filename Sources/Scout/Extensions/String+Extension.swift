import Foundation

extension String {

    /// The NSRange of the full string
    var nsRange: NSRange { NSRange(location: 0, length: count) }

    subscript(_ range: Range<Int>) -> Substring {
        let sliceStartIndex = index(startIndex, offsetBy: range.lowerBound)
        let sliceEndIndex = index(startIndex, offsetBy: range.upperBound - 1)

        return self[sliceStartIndex...sliceEndIndex]
    }

    subscript(_ range: NSRange) -> Substring {
        let sliceStartIndex = index(startIndex, offsetBy: range.location)
        let sliceEndIndex = index(startIndex, offsetBy: range.upperBound - 1)

        return self[sliceStartIndex...sliceEndIndex]
    }
}
