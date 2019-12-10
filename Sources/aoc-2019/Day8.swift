extension Array where Element: Equatable {
    func count(of value: Element) -> Int {
        return self.filter { $0 == value }.count
    }
}

enum Color: Int {
    case black = 0,
        white = 1,
        transparent = 2
}

func resolveColor(_ values: [Color]) -> Color {
    var next = values[0]
    var idx = 0
    while .transparent == next && idx < values.count {
        next = values[idx]
        idx += 1
    }
    return next
}

func day8() throws {
    let password = try readLines(forDay: 8)[0].map { Color(rawValue: Int(String($0))!)! }

    let width = 25
    let height = 6
    let digitsPerLayer = width * height
    let layerCount = password.count / digitsPerLayer

    // split digits by layer
    let layers = (0..<layerCount).map { i in
        Array(password[(i * digitsPerLayer)..<((i * digitsPerLayer + digitsPerLayer))])
    }

    // find the layer with the least black pixels
    let layerWithLeastZeros = zip(layers.indices, layers).min { $0.1.count(of: .black) < $1.1.count(of: .black) }!.0

    // multiply counts of white and transparent pixels
    let oneDigits = layers[layerWithLeastZeros].count(of: .white)
    let twoDigits = layers[layerWithLeastZeros].count(of: .transparent)
    print("Part 1: \(oneDigits * twoDigits)")

    // for each pixel position calculate which pixel is visible
    let visiblePixels = (0..<digitsPerLayer).map { idx in
        layers.map { [$0[idx]] }.reduce([], +)
    }.map { resolveColor($0) }

    print("Part 2:")
    // create a semi readable visual representation of the data
    for i in stride(from: 0, to: visiblePixels.count, by: width) {
        print(visiblePixels[i..<(i + width)].map { digit in
            digit.rawValue == 0 ? " " : "■"
        }.reduce("", +) )
    }
}
