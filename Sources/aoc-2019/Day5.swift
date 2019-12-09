func day5() throws {
    let program = try readLines(forDay: 5)[0].split(separator: ",").map { Int($0)! }

    // Part 1. The final output value printed is the answer.
    var computer1 = Computer(program: program, inputs: [1])
    computer1.runProgramUntilComplete()
    print("Part 1: \(computer1.outputs.last!)")

    var computer2 = Computer(program: program, inputs: [5])
    computer2.runProgramUntilComplete()
    print("Part 2: \(computer2.outputs.last!)")
}
