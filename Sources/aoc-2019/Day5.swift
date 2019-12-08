func day5() throws {
    let program = try readLines(forDay: 5)[0].split(separator: ",").map { Int($0)! }

    // Part 1. The final output value printed is the answer.
    let results1 = compute(program: program, inputs: [1]) // enter 1: outputs 7286649
    print("Part 1: \(results1.1.last!)")

    let results2 = compute(program: program, inputs: [5]) // enter 5: outputs 15724522
    print("Part 2: \(results2.1.last!)")
}
