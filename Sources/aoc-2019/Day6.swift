/// Given an object and a map of object names to direct orbiters, returns an array containing all of the objects that
/// both directly and indirectly orbit the specified object.
func getOrbiters(of object: String, orbits: [String: [String]]) -> [String] {
    // if this object has no direct orbiters, it has no orbiters period
    guard let directOrbiters = orbits[object] else { return [] }
    // add the direct orbiters
    var orbiters = directOrbiters
    // for each direct orbiter, recursively retrieve its orbiters to get all indirect orbiters
    for obj in directOrbiters {
        orbiters += getOrbiters(of: obj, orbits: orbits)
    }
    return orbiters
}

func day6() throws {
    let orbitData = try readLines(forDay: 6).map { $0.split(separator: ")").map { String($0) } }

    // part 1

    // create a map of objects to lists of objects that orbit them
    var orbits = [String: [String]]()
    orbitData.forEach { orbit in
        orbits[orbit[0]] = orbits[orbit[0], default: []] + [orbit[1]]
    }

    // sum up the total # objects orbiting each object in the graph 
    let totalCount = orbits.keys.map { getOrbiters(of: $0, orbits: orbits).count }.reduce(0, +)
    print("Part 1: \(totalCount) direct and indirect orbits")

    // part 2

    // find the objects we are looking for a path between
    let start = orbits.first { $0.1.contains("YOU") }!.key
    let end = orbits.first { $0.1.contains("SAN") }!.key

    // construct a map of [Object: [neighboring object]]
    // we have all of the obj -> orbiter edges, now we just need to add the reverse directions.
    var neighbors = orbits
    orbitData.forEach { orbit in
        neighbors[orbit[1]] = neighbors[orbit[1], default: []] + [orbit[0]]
    }

    // now perform a breadth-first search to find the shortest path

    var visited = Set<String>() // track nodes we've already visited to prevent cycles
    var level = neighbors[start]! // assume start node is connected to graph
    var depth = 1 // track how many levels away from the start we've visited
    while level.count > 0 {
        var nextLevel = [String]()
        for obj in level {
            if obj == end {
                print("Part 2: Found path with length \(depth)")
                return
            }
            visited.insert(obj)
            // add to the next level any children we haven't visited already
            if let objNeighbors = neighbors[obj] {
                nextLevel += objNeighbors.filter { !visited.contains($0) }
            }
        }
        // we've exhausted this level, move on to the next one
        depth += 1
        level = nextLevel
    }

    print("Part 2: No path found")
}
