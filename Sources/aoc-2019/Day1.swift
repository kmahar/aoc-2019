/// Code for solving day 1

/// Calculate the fuel required for a given mass: "divide by three, round down, and subtract 2."
func fuel(forMass mass: Int) -> Int {
    return (mass / 3) - 2
}

/// Calculates the total fuel required for a given mass, including extra fuel for the weight of the fuel itself.
func totalFuel(forMass mass: Int) -> Int {
    // "Any mass that would require negative fuel should instead be treated as if it requires zero fuel."
    guard mass > 0 else {
        return 0
    }
    let fuelForMass = max(0, fuel(forMass: mass))
    return fuelForMass + totalFuel(forMass: fuelForMass)
}

func day1() throws {
    // assumes input file is well-formed.
    let data = try readLines(forDay: 1).map { Int($0)! }

    let part1 = data.map(fuel).reduce(0, +)
    print("Answer to part 1: \(part1)")

    let part2 = data.map(totalFuel).reduce(0, +)
    print("Answer to part 2: \(part2)")
}
