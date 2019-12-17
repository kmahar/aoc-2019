import Foundation

enum TileId: Int {
    case empty = 0,
        wall = 1,
        block = 2,
        paddle = 3,
        ball = 4
}

/// Produces inputs to the pinball game based on the current positions of the ball and paddle.
class GameInputProducer: InputProducer {
    var ballX: Int
    var paddleX: Int

    init(ballX: Int, paddleX: Int) {
        self.ballX = ballX
        self.paddleX = paddleX
    }

    func nextValue() -> Int {
        // track the movement of the ball with the paddle
        if paddleX == ballX {
            return 0
        } else if paddleX < ballX {
            return 1
        } else {
            return -1
        }
    }
}

func day13() throws {
    let program = try readIntcodeProgram(forDay: 13) + Array(repeating: 0, count: 1000)
    var computer = Computer(program: program)
    computer.runProgramUntilComplete()

    let outputs = computer.outputs
    var tiles = [Point: TileId]()

    for i in stride(from: 0, to: outputs.count, by: 3) {
        tiles[Point(outputs[i], outputs[i + 1])] = TileId(rawValue: outputs[i + 2])!
    }

    let blockCount = tiles.filter { $0.value == .block }.count
    print("Part 1: \(blockCount)")

    let xMin = tiles.map { $0.key.x }.min()!
    let xMax = tiles.map { $0.key.x }.max()!

    let yMin = tiles.map { $0.key.y }.min()!
    let yMax = tiles.map { $0.key.y }.max()!

    let ballX = tiles.filter { $0.value == .ball }[0].key.x
    let paddleX = tiles.filter { $0.value == .paddle }[0].key.x
    let inputProducer = GameInputProducer(ballX: ballX, paddleX: paddleX)

    var programCopy = program
    // Memory address 0 represents the number of quarters that have been inserted; set it to 2 to play for free.
    programCopy[0] = 2
    var computer2 = Computer(program: programCopy, inputProducer: inputProducer)

    var score = 0
    while true {
        // if we can't get three more outputs, assume program has halted
        guard let x = computer2.runProgramUntilNextOutput(),
            let y = computer2.runProgramUntilNextOutput(),
            let next = computer2.runProgramUntilNextOutput() else {
            break
        }
        // update score
        guard !(x == -1 && y == 0) else {
            score = next
            continue
        }

        guard let nextTile = TileId(rawValue: next) else {
            print("Unrecognized tile id \(next)")
            break
        }

        switch nextTile {
        case tiles[Point(x, y)]:
            // no change, no need to update or reprint screen
            continue
        case .ball:
            inputProducer.ballX = x
        case .paddle:
            inputProducer.paddleX = x
        default:
            break
        }

        tiles[Point(x, y)] = nextTile

        // start: visualization (comment out to run code faster)
        print("\n\n\n\n\n\n")
        print("Score: \(score)")
        let disp = (yMin...yMax).map { y in
            (xMin...xMax).map { x in
                let id = tiles[Point(x, y)]!
                switch id {
                case .empty:
                    return " "
                case .wall:
                    return "|"
                case .block:
                    return "■"
                case .paddle:
                    return "-"
                case .ball:
                    return "◯"
                }
            }.reduce("", +) + "\n"
        }.reduce("", +)
        print(disp)
        usleep(50000) // sleep so display in terminal isn't jumpy
        // end: visualization
    }

    print("Part 2: \(score)")
}
