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
        relativeBaseOffset = 9,
        halt = 99
}

/// Possible modes for a parameter in an Intcode program.
enum Mode: Int {
    case position = 0,
        immediate = 1,
        relative = 2
}

/// An instruction in an Intcode computer.
struct Instruction {
    let opcode: Opcode
    let parameters: [Int]
    // +1 for the opcode
    var length: Int { return parameters.count + 1 }
}

/// A type that produces an endless series of inputs for an Intcode program.
protocol InputProducer {
    func nextValue() -> Int
}

/// An Intcode computer.
struct Computer {
    /// The program this computer should run.
    var program: [Int]
    /// Stores any inputs that should be provided to the program. If provided, the computer will use up these inputs
    /// before using the input provider.
    var inputs: [Int]
    /// An optional input producer this program should use for getting inputs. This producer will only be used when the
    /// provided inputs array is empty.
    let inputProducer: InputProducer?
    /// Stores outputs that the program produces while running.
    var outputs: [Int] = []
    /// The instruction pointer.
    var iP: Int = 0
    /// The relative base value.
    var relativeBase = 0
    /// Indicates whether the program has halted.
    var isHalted = false

    /// Initializes a new Computer with a program to run and an optionally provided array of inputs.
    init(program: [Int], inputs: [Int] = [], inputProducer: InputProducer? = nil) {
        self.program = program
        self.inputs = inputs
        self.inputProducer = inputProducer
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
                return self.program[idx]
            case .immediate:
                return idx
            case .relative:
                return self.relativeBase + self.program[idx]
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
            let params = self.readParams(count: 3)
            return Instruction(opcode: opcode, parameters: params)
        case .jumpIfTrue, .jumpIfFalse:
            let params = self.readParams(count: 2)
            return Instruction(opcode: opcode, parameters: params)
        case .input, .output, .relativeBaseOffset:
            let params = self.readParams(count: 1)
            return Instruction(opcode: opcode, parameters: params)
        case .halt:
            return Instruction(opcode: opcode, parameters: [])
        }
    }

    /// Executes the next instruction in the program. Has no effect if the program has already halted or if the
    /// instruction pointer reaches the end of the program.
    mutating func step() {
        guard !self.isHalted && self.iP < self.program.count else {
            return
        }
        let instruction = self.readNextInstruction()
        let params = instruction.parameters
        switch instruction.opcode {
        case .add:
            self.program[params[2]] = self.program[params[0]] + self.program[params[1]]
        case .multiply:
            self.program[params[2]] = self.program[params[0]] * self.program[params[1]]
        case .equals:
            self.program[params[2]] = self.program[params[0]] == self.program[params[1]] ? 1 : 0
        case .lessThan:
            self.program[params[2]] = self.program[params[0]] < self.program[params[1]] ? 1 : 0
        case .input:
            if self.inputs.count > 0 {
                self.program[params[0]] = self.inputs.removeFirst()
            } else if let producer = self.inputProducer {
                self.program[params[0]] = producer.nextValue()
            } else {
                fatalError("no way to get more input")
            }
        case .output:
            self.outputs.append(self.program[params[0]])
        case .jumpIfTrue:
            if self.program[params[0]] != 0 {
                self.iP = self.program[params[1]]
                return // return to avoid incrementing iP below
            }
        case .jumpIfFalse:
            if self.program[params[0]] == 0 {
                self.iP = self.program[params[1]]
                return // return to avoid incrementing iP below
            }
        case .relativeBaseOffset:
            self.relativeBase += self.program[params[0]]
        case .halt:
            self.isHalted = true
            return
        }
        self.iP += instruction.length
    }

    /// Runs the program until it next produces output or until the program halts. If an output is produced, returns
    /// the output. If the program halts, returns nil.
    mutating func runProgramUntilNextOutput() -> Int? {
        while self.iP < self.program.count && !self.isHalted && self.outputs.count == 0 {
            self.step()
        }
        return self.outputs.count > 0 ? self.takeOutput() : nil
    }

    /// Runs the program until it halts.
    mutating func runProgramUntilComplete() {
        // iterate through the instructions.
        while self.iP < self.program.count && !self.isHalted {
            self.step()
        }
    }
}

func readIntcodeProgram(forDay day: Int) throws -> [Int] {
    return try readLines(forDay: day)[0].split(separator: ",").map { Int($0)! }
}
