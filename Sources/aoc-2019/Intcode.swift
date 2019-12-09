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

/// An instruction in an Intcode computer.
struct Instruction {
    let opcode: Opcode
    let parameters: [Int]
    // +1 for the opcode
    var length: Int { return parameters.count + 1 }
}

/// An Intcode computer.
struct Computer {
    /// The program this computer should run.
    var program: [Int]
    /// Stores any inputs that should be provided to the program.
    var inputs: [Int]
    /// Stores outputs that the program produces while running.
    var outputs: [Int] = []
    /// The instruction pointer.
    var iP: Int = 0
    /// Indicates whether the program has halted.
    var halted = false

    /// Initializes a new Computer with a program to run and an optionally provided array of inputs.
    init(program: [Int], inputs: [Int] = []) {
        self.program = program
        self.inputs = inputs
    }

    /// Takes an output of the program in FIFO order. Assumes an output is available.
    mutating func takeOutput() -> Int {
        return self.outputs.removeFirst()
    }

    /// Reads parameters for an instruction beginning at the instruction pointer's current location.
    func readParams(count: Int) -> [Int] {
        // remove the trailing two digits, which are the opcode
        var modeData = self.program[iP] / 100
        var modes = [Mode]()
        for _ in 0..<count {
            let lastDigit = modeData % 10
            let mode = Mode(rawValue: lastDigit)!
            modes.append(mode)
            modeData /= 10
        }

        return (0..<count).map { i in
            let idx = self.iP + 1 + i
            switch modes[i] {
            case .position:
                return self.program[program[idx]]
            case .immediate:
                return self.program[idx]
            }
        }
    }

    /// Reads the next instruction at the current address of the instruction pointer.
    func readNextInstruction() -> Instruction {
        let first = self.program[iP]
        // assume valid opcode. % 100 to get last two digits.
        let opcode = Opcode(rawValue: first % 100)!

        switch opcode {
        case .add, .multiply, .equals, .lessThan:
            let params = self.readParams(count: 2)
            return Instruction(opcode: opcode, parameters: params + [self.program[self.iP + 3]])
        case .jumpIfTrue, .jumpIfFalse:
            let params = self.readParams(count: 2)
            return Instruction(opcode: opcode, parameters: params)
        case .input:
            return Instruction(opcode: opcode, parameters: [self.program[self.iP + 1]])
        case .output:
            let params = self.readParams(count: 1)
            return Instruction(opcode: opcode, parameters: params)
        case .halt:
            return Instruction(opcode: opcode, parameters: [])
        }
    }

    /// Executes the next instruction in the program. Has no effect if the program has already halted or if the
    /// instruction pointer reaches the end of the program.
    mutating func step() {
        guard !self.halted && self.iP < program.count else {
            return
        }
        let instruction = self.readNextInstruction()
        let params = instruction.parameters
        switch instruction.opcode {
        case .add:
            self.program[params[2]] = params[0] + params[1]
        case .multiply:
            self.program[params[2]] = params[0] * params[1]
        case .equals:
            self.program[params[2]] = params[0] == params[1] ? 1 : 0
        case .lessThan:
            self.program[params[2]] = params[0] < params[1] ? 1 : 0
        case .input:
            self.program[params[0]] = self.inputs.removeFirst()
        case .output:
            self.outputs.append(params[0])
        case .jumpIfTrue:
            if params[0] != 0 {
                self.iP = params[1]
                return // return to avoid incrementing iP below
            }
        case .jumpIfFalse:
            if params[0] == 0 {
                self.iP = params[1]
                return // return to avoid incrementing iP below
            }
        case .halt:
            self.halted = true
            return
        }
        self.iP += instruction.length
    }

    /// Runs the program until it next produces output or until the program halts. If an output is produced, returns
    /// the output. If the program halts, returns nil.
    mutating func runProgramUntilNextOutput() -> Int? {
        while self.iP < self.program.count && !self.halted && self.outputs.count == 0 {
            self.step()
        }
        return self.outputs.count > 0 ? self.takeOutput() : nil
    }

    /// Runs the program until it halts.
    mutating func runProgramUntilComplete() {
        // iterate through the instructions.
        while self.iP < self.program.count && !self.halted {
            self.step()
        }
    }
}
