/// Possible opcodes in an Intcode program.
enum Opcode: Int {
    case add = 1,
        multiply = 2,
        input = 3,
        output = 4,
        jumpIfTrue = 5,
        jumpIfFalse = 6,
        lessThan = 7,
        equals = 8,
        halt = 99
}

/// Possible modes for a parameter in an Intcode program.
enum Mode: Int {
    case position = 0,
        immediate = 1

}

/// Parses the requested number of parameter modes from the first value in an instruction.
func parseModes(value: Int, count: Int) -> [Mode] {
    // remove the trailing two digits, which are the opcode
    var modeData = value / 100
    var modes = [Mode]()
    for _ in 0..<count {
        let lastDigit = modeData % 10
        let mode = Mode(rawValue: lastDigit)!
        modes.append(mode)
        modeData /= 10
    }
    return modes
}

/// Given data, an instruction's start index, and a count of parameters, returns
/// the instruction's parameters.
func getParams(from data: [Int], startIndex: Int, count: Int) -> [Int] {
    let modes = parseModes(value: data[startIndex], count: count)
    return (0..<count).map { i in
        let idx = startIndex + 1 + i
        switch modes[i] {
        case .position:
            return data[data[idx]]
        case .immediate:
            return data[idx]
        }
    }
}

struct Instruction {
    let opcode: Opcode
    let parameters: [Int]
    // +1 for the opcode
    var length: Int { return parameters.count + 1 }
}

func readInstruction(from data: [Int], startIndex: Int) -> Instruction {
    let first = data[startIndex]
    // assume valid opcode. % 100 to get last two digits.
    let opcode = Opcode(rawValue: first % 100)!

    switch opcode {
    case .add, .multiply, .equals, .lessThan:
        let params = getParams(from: data, startIndex: startIndex, count: 2)
        return Instruction(opcode: opcode, parameters: params + [data[startIndex + 3]])
    case .jumpIfTrue, .jumpIfFalse:
        let params = getParams(from: data, startIndex: startIndex, count: 2)
        return Instruction(opcode: opcode, parameters: params)
    case .input:
        return Instruction(opcode: opcode, parameters: [data[startIndex + 1]])
    case .output:
        let params = getParams(from: data, startIndex: startIndex, count: 1)
        return Instruction(opcode: opcode, parameters: params)
    case .halt:
        return Instruction(opcode: opcode, parameters: [])
    }
}

/// Given a program described by an `[Int]`, runs the program and returns the final value contained at address 0.
func compute(program: [Int]) -> Int {
    var mem = program
    var iP = 0
    // iterate through the instructions.
    while iP < mem.count {
        let instruction = readInstruction(from: mem, startIndex: iP)
        let params = instruction.parameters
        switch instruction.opcode {
        case .add:
            mem[params[2]] = params[0] + params[1]
        case .multiply:
            mem[params[2]] = params[0] * params[1]
        case .equals:
            mem[params[2]] = params[0] == params[1] ? 1 : 0
        case .lessThan:
            mem[params[2]] = params[0] < params[1] ? 1 : 0
        case .input:
            print("Provide an input: ", terminator: "")
            mem[params[0]] = Int(readLine()!)!
        case .output:
            print("Output: \(params[0])")
        case .jumpIfTrue:
            if params[0] != 0 {
                iP = params[1]
                continue // continue to avoid incrementing iP below
            }
        case .jumpIfFalse:
            if params[0] == 0 {
                iP = params[1]
                continue // continue to avoid incrementing iP below
            }
        case .halt:
            return mem[0]
        }
        iP += instruction.length
    }
    // we should never get here assuming the program eventually contains a `halt` opcode.
    return mem[0]
}
