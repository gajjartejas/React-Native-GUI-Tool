import Foundation

/// Project ordering policy without a SwiftUI collection extension dependency.
enum ProjectOrdering {
    static func moving(_ projects: [ProjectInfo], fromOffsets source: IndexSet, toOffset destination: Int) -> [ProjectInfo] {
        let moved = source.map { projects[$0] }
        var result = projects.enumerated().filter { !source.contains($0.offset) }.map(\.element)
        let insertionIndex = destination - source.filter { $0 < destination }.count
        result.insert(contentsOf: moved, at: insertionIndex)
        return result
    }
}
