/// The possible directions a wire can go.
enum Direction: String {
    case left = "L",
        right = "R",
        up = "U",
        down = "D"
}

/// A move in a wire's path.
struct Move {
    let direction: Direction
    let distance: Int

    init(_ input: String) {
        self.direction = Direction(rawValue: String(input.first!))!
        self.distance = Int(input.dropFirst())!
    }
}

/// Given a wire's path, returns a list of all of the points the wire visited, in order. Assumes the wire started at
/// the origin.
func getVisitedPoints(on path: [Move]) -> [Point] {
    var visited = [Point]()
    // initial position is origin
    var pos = Point(0, 0)
    path.forEach { move in
        switch move.direction {
        case .left:
            for x in (pos.x - move.distance)..<pos.x {
                visited.append(Point(x, pos.y))
            }
            pos = Point(pos.x - move.distance, pos.y)
        case .right:
            for x in (pos.x + 1)...(pos.x + move.distance) {
                visited.append(Point(x, pos.y))
            }
            pos = Point(pos.x + move.distance, pos.y)
        case .down:
            for y in (pos.y - move.distance)..<pos.y {
                visited.append(Point(pos.x, y))
            }
            pos = Point(pos.x, pos.y - move.distance)
        case .up:
            for y in (pos.y + 1)...pos.y + move.distance {
                visited.append(Point(pos.x, y))
            }
            pos = Point(pos.x, pos.y + move.distance)
        }
    }
    return visited
}

func day3() throws {
    // Get an [[Point]], where each array corresponds to the points visited by a wire.
    let visitedPoints = try readLines(forDay: 3)
        .map { $0.split(separator: ",").map { Move(String($0)) } }
        .map(getVisitedPoints)

    // Find the set intersection of all the points visited by each wire.
    let visitedSets = visitedPoints.map(Set.init)
    let intersections = visitedSets[1...].reduce(visitedSets[0], { $0.intersection($1) })

    // Find which intersection is closest to the origin.
    let closestToOrigin = intersections.min { $0.distFromOrigin < $1.distFromOrigin }
    print("Part 1 answer: \(closestToOrigin?.distFromOrigin ?? -1)")

    // For each intersection, find the first index of that intersection in the path taken by each wire.
    // Sum the value across all wires to get the total number of steps to reach the intersection.
    var steps = [Point: Int]()
    intersections.forEach { intersection in
        // + 1 is to account for the origin not being at the start of each list.
        steps[intersection] = visitedPoints.map { $0.firstIndex(of: intersection)! + 1 }.reduce(0, +)
    }
    // Find the intersection with the lowest number of steps.
    let fewestSteps = steps.min { $0.value < $1.value }
    print("Part 2 answer: \(fewestSteps?.value ?? -1)")
}
