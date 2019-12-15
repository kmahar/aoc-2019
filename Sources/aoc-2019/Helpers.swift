import Foundation

/// Helper functions for use across multiple days.

/// Reads the lines from a file corresponding to a given day.
func readLines(forDay day: Int) throws -> [String.SubSequence] {
    let path = URL(fileURLWithPath: "./Inputs/\(day)")
    return try String(contentsOf: path, encoding: .utf8)
                .split(separator: "\n")
}

struct Point: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    var distFromOrigin: Int {
        abs(self.x) + abs(self.y)
    }
}

let days: [Int: () throws -> Void] = [
    1: day1,
    2: day2,
    3: day3,
    4: day4,
    5: day5,
    6: day6,
    7: day7,
    8: day8,
    9: day9,
    10: day10,
    11: day11,
    12: day12,
    13: day13,
    14: day14,
    15: day15,
    16: day16,
    17: day17,
    18: day18,
    19: day19,
    20: day20,
    21: day21,
    22: day22,
    23: day23,
    24: day24,
    25: day25    
]

/// Runs the solution for the provided day, if it exists.
func runDay(_ day: Int) throws {
    if let dayFunc = days[day] {
        try dayFunc()
    } else {
        print("No solution for day \(day)")
    }
}
