import Foundation

extension Point {
    /// Returns true if this point has an unobstructed view of `otherPoint`. Returns false if any of the asteroids in
    /// `asteroids` obstruct its view.
    func canDetect(_ otherPoint: Point, asteroids: [Point]) -> Bool {
        guard self != otherPoint else {
            return false
        }

        for i in 0..<asteroids.count {
            let a = asteroids[i]
            // disregard both of the points involved if they are in the list
            guard a != self && a != otherPoint else {
                continue
            }
            // if we found an obstruction return false
            if areInALine(p1: self, p2: a, p3: otherPoint) {
                return false
            }
        }
        return true
    }

    // Calculates the angle of the vector from this point to the provided point, relative to the positive x-axis.
    func angle(to otherPoint: Point) -> Double {
        // adjust the other point as if self is the origin, to simplify angle calculations.
        let adjustedPoint = Point(otherPoint.x - self.x, otherPoint.y - self.y)
        return (360 + atan2(Double(adjustedPoint.y), Double(adjustedPoint.x)) * 180/Double.pi).truncatingRemainder(dividingBy: 360)
    }
}

/// Returns true if p1, p2, and p3 are colinear and p2 is between p1 and p3.
func areInALine(p1: Point, p2: Point, p3: Point) -> Bool {
    let slope1 = Double(p1.y - p2.y) / Double(p1.x - p2.x)
    let slope2 = Double(p2.y - p3.y) / Double(p2.x - p3.x)

    return slope1 == slope2 && // in a line
        min(p1.x, p3.x) <= p2.x && max(p1.x, p3.x) >= p2.x && // p2's x coordinate is between p1 and p3's
        min(p1.y, p3.y) <= p2.y && max(p1.y, p3.y) >= p2.y    // p3's y coordinate is between p1 and p3's
}

func day10() throws {
    let input = try readLines(forDay: 10).map { Array($0).map { $0 == "#" } }

    // create a [Point] containing all of the asteroid locations
    let asteroids = (0..<input[0].count).map { x in
        (0..<input.count).map { y in
            input[y][x] ? Point(x, y) : nil
        }.compactMap { $0 }
    }.reduce([], +)

    // for each point, see how many asteroids it can detect
    var detectableCounts = [Point: Int]()
    for i in 0..<asteroids.count {
        detectableCounts[asteroids[i]] = (0..<asteroids.count).map { j in
            asteroids[i].canDetect(asteroids[j], asteroids: asteroids) ? 1 : 0
        }.reduce(0, +)
    }

    let bestLocation = detectableCounts.max { $0.value < $1.value }!
    print("Part 1: \(bestLocation.value) asteroids are visible from \(bestLocation.key)")

    // for the sake of making angle calculations easier to reason about, convert all the coordinates
    // to a normal coordinate system
    let normalizedAsteroids = asteroids.map { Point($0.x, -1 * $0.y) }
    let normalizedOrigin = Point(bestLocation.key.x, -1 * bestLocation.key.y)

    // calculate the angles from the monitoring station to each asteroid
    var angles = [Point: Double]()
    for point in normalizedAsteroids where point != normalizedOrigin {
        angles[point] = normalizedOrigin.angle(to: point)
    }

    // sort the angles into the order we will pass through them. we start at 90 degrees, rotate down to 0, and then
    // rotate from 359 down to 90
    var sortedByAngle = angles.sorted {
        let aInFirstQuadrant = $0.value <= 90 && $0.value >= 0
        let bInFirstQuadrant = $1.value <= 90 && $1.value >= 0

        switch (aInFirstQuadrant, bInFirstQuadrant) {
        // if both a and b are in quadrant 1, just return whichever angle is larger (closer to 90)
        // similarly, if both are not in quadrant 1, return whichever angle is larger (closer to 359)
        case (true, true), (false, false):
            return $0.value > $1.value
        // if a is quadrant 1 and b isn't, we will definitely see a first
        case (true, false):
            return true
        // if b is in quadrant 1 and a isn't, we will definitely see b first
        case (false, true):
            return false
        }
    }.map { $0.key }

    var destroyed = [Point]()
    // while we haven't yet destroyed 200 asteroids, continually loop and remove whichever asteroids we will destroy in
    // the next 360 degree rotation
    while destroyed.count < 200 {
        var remaining = [Point]()
        sortedByAngle.forEach { point in
            if normalizedOrigin.canDetect(point, asteroids: sortedByAngle) {
                destroyed.append(point)
            } else {
                remaining.append(point)
            }
        }
        sortedByAngle = remaining
    }

    let answer = destroyed[199]
    print("Part 2: \(100 * answer.x + -1 * answer.y)")
}
