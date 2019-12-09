func day2() throws {
    let program = try readLines(forDay: 2)[0].split(separator: ",").map { Int($0)! }

    var part1Program = program
    part1Program[1] = 12
    part1Program[2] = 2
    var computer = Computer(program: part1Program)
    computer.runProgramUntilComplete()
    print("Part 1: \(computer.program[0])")

    let target = 19690720

    for noun in 0...99 {
        for verb in 0...99 {
            var testProgram = program
            testProgram[1] = noun
            testProgram[2] = verb
            var computer = Computer(program: testProgram)
            computer.runProgramUntilComplete()
            if computer.program[0] == target {
                print("Part 2: \(100 * noun + verb)")
                return
            }
        }
    }
}
