func day9() throws {
    let program = try readIntcodeProgram(forDay: 9) + Array(repeating: 0, count: 1000)
    var computer1 = Computer(program: program, inputs: [1])
    computer1.runProgramUntilComplete()
    print("Part 1: \(computer1.takeOutput())")

    var computer2 = Computer(program: program, inputs: [2])
    computer2.runProgramUntilComplete()
    print("Part 2: \(computer2.takeOutput())")
}
