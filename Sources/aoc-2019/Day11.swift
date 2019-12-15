enum PaintColor: Int {
    case black = 0,
        white = 1
}

enum TurnDirection: Int {
    case left = 0,
        right = 1
}

enum Angle {
    case up, down, left, right
}

struct HullPaintingRobot {
    var location = Point(0, 0)
    var currentAngle: Angle = .up
    var painted = [Point: PaintColor]()
    var brain: Computer
    let initialPanelColor: PaintColor

    init(program: [Int], initialPanelColor: PaintColor) {
        self.brain = Computer(program: program)
        self.initialPanelColor = initialPanelColor
    }

    mutating func run() {
        self.brain.inputs.append(self.initialPanelColor.rawValue)
        while !self.brain.isHalted {
            guard let colorToPaint = self.brain.runProgramUntilNextOutput() else {
                return
            }
            let color = PaintColor(rawValue: colorToPaint)!
            self.painted[self.location] = color
            guard let directionToTurn = self.brain.runProgramUntilNextOutput() else {
                return
            }
            let direction = TurnDirection(rawValue: directionToTurn)!
            switch (self.currentAngle, direction) {
            case (.up, .left), (.down, .right):
                self.currentAngle = .left
                self.location = Point(self.location.x - 1, self.location.y)
            case (.up, .right), (.down, .left):
                self.currentAngle = .right
                self.location = Point(self.location.x + 1, self.location.y)
            case (.left, .left), (.right, .right):
                self.currentAngle = .down
                self.location = Point(self.location.x, self.location.y - 1)
            case (.left, .right), (.right, .left):
                self.currentAngle = .up
                self.location = Point(self.location.x, self.location.y + 1)
            }

            if let currentColor = self.painted[self.location] {
                self.brain.inputs.append(currentColor.rawValue)
            } else {
                // initially, all panels are black
                self.brain.inputs.append(0)
            }
        }
    }
}

func day11() throws {
    let program = try readIntcodeProgram(forDay: 11) + Array(repeating: 0, count: 1000)
    var robot1 = HullPaintingRobot(program: program, initialPanelColor: .black)
    robot1.run()
    print("Part 1: \(robot1.painted.count)")

    var robot2 = HullPaintingRobot(program: program, initialPanelColor: .white)
    robot2.run()

    let xValues = robot2.painted.keys.map { $0.x }
    let yValues = robot2.painted.keys.map { $0.y }
    let minX = xValues.min()!
    let maxX = xValues.max()!
    let minY = yValues.min()!
    let maxY = yValues.max()!

    print("Part 2:")
    // reversed so we print top to bottom
    for y in (minY...maxY).reversed() {
        let row = (minX...maxX).map { x in
            if let color = robot2.painted[Point(x, y)] {
                return color == .white ? "■" : " "
            }
            return " "
        }.reduce("", +)
        print(row)
    }
}
