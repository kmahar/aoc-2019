import Foundation

/// Helper functions for use across multiple days.

/// Reads the lines from a file corresponding to a given day.
func readLines(forDay day: Int) throws -> [String.SubSequence] {
    let path = URL(fileURLWithPath: "./Inputs/\(day)")
    return try String(contentsOf: path, encoding: .utf8)
                .split(separator: "\n")
}

let days: [Int: () throws -> Void] = [
    1: day1,
    2: day2,
    3: day3
]

/// Runs the solution for the provided day, if it exists.
func runDay(_ day: Int) throws {
    if let dayFunc = days[day] {
        try dayFunc()
    } else {
        print("No solution for day \(day)")
    }
}
