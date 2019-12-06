func day2() throws {
    let program = try readLines(forDay: 2)[0].split(separator: ",").map { Int($0)! }

    var part1Program = program
    part1Program[1] = 12
    part1Program[2] = 2
    print("Part 1: \(compute(program: part1Program))")

    let target = 19690720

    for noun in 0...99 {
        for verb in 0...99 {
            var testProgram = program
            testProgram[1] = noun
            testProgram[2] = verb
            if compute(program: testProgram) == target {
                print("Part 2: \(100 * noun + verb)")
                return
            }
        }
    }
}
