func day5() throws {
    let program = try readLines(forDay: 5)[0].split(separator: ",").map { Int($0)! }

    // Part 1. The final output value printed is the answer.
    print("Part 1:")
    _ = compute(program: program) // enter 1: outputs 7286649

    print("-------")
    print("Part 2:")
    _ = compute(program: program) // enter 5: outputs 15724522
}
