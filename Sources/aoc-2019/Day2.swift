/// Represents possible opcodes in an Intcode program.
enum Opcode: Int {
    case add = 1,
        multiply = 2,
        halt = 99
}

/// Given a program described by an `[Int]` and two inputs to the program, returns the program's output.
func compute(program: [Int], input1: Int, input2: Int) -> Int {
    var mem = program
    // input arguments to memory.
    mem[1] = input1
    mem[2] = input2

    // iterate through the instructions.
    for iP in stride(from: 0, to: mem.count, by: 4) {
        let value = mem[iP]
        // assume valid opcode.
        let opcode = Opcode(rawValue: value)!
        switch opcode {
        case .add:
            mem[mem[iP + 3]] = mem[mem[iP + 1]] + mem[mem[iP + 2]]
        case .multiply:
            mem[mem[iP + 3]] = mem[mem[iP + 1]] * mem[mem[iP + 2]]
        case .halt:
            return mem[0]
        }
    }
    // we should never get here assuming the program eventually contains a `halt` opcode.
    return mem[0]
}

func day2() throws {
    let program = try readLines(forDay: 2)[0].split(separator: ",").map { Int($0)! }

    print("Part 1: \(compute(program: program, input1: 12, input2: 2))")

    let target = 19690720

    for noun in 0...99 {
        for verb in 0...99 {
            if compute(program: program, input1: noun, input2: verb) == target {
                print("Part 2: \(100 * noun + verb)")
                return
            }
        }
    }
}
