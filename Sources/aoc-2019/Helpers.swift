import Foundation

/// Helper functions for use across multiple days.

/// Given a day, parses the integers from the file corresponding to that day.
func parseIntegersFromFile(forDay day: Int) throws -> [Int] {
    let path = URL(fileURLWithPath: "./Inputs/\(day)")
    return try String(contentsOf: path, encoding: .utf8)
                .split(separator: "\n")
                .map { Int($0)! } // assumes all input files are well-formed.
}

let days: [Int: () throws -> Void] = [
    1: day1
]

/// Runs the solution for the provided day, if it exists.
func runDay(_ day: Int) throws {
    if let dayFunc = days[day] {
        try dayFunc()
    } else {
        print("No solution for day \(day)")
    }
}
