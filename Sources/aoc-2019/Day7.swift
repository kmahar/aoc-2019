/// Given an array of integers, generates all possible permutations of that array. Assumes no duplicate elements.
func generatePermutations(of list: [Int]) -> [[Int]] {
    // Only permutation of a list of length 1 or 0 is the list itself.
    guard list.count > 1 else {
        return [list]
    }

    // For each element in the list, recursively generate all permutations that start with that element.
    return (0..<list.count).map { i in
        let elt = list[i]
        var copy = list
        copy.remove(at: i)
        return generatePermutations(of: copy).map { [elt] + $0 }
    }.reduce([], +)
}

func day7() throws {
    let data = try readIntcodeProgram(forDay: 7)

    // part 1
    let phaseCombinations = generatePermutations(of: [0, 1, 2, 3, 4])
    let maxSignal1: Int = phaseCombinations.map { combo in
        var nextInput = 0
        for i in 0...4 {
            var computer = Computer(program: data, inputs: [combo[i], nextInput])
            computer.runProgramUntilComplete()
            nextInput = computer.takeOutput()
        }
        return nextInput
    }.max()!

    print("Part 1: \(maxSignal1)")

    // part 2
    let phaseCombinations2 = generatePermutations(of: [5, 6, 7, 8, 9])
    let maxSignal2: Int = phaseCombinations2.map { combo in
        var amplifiers = combo.map { Computer(program: data, inputs: [$0]) }
        var nextInput = 0 // starting input
        // while no amplifers are halted, continually loop over all amplifiers,
        // passing the last output we've seen in as the next input
        while !amplifiers.contains { $0.isHalted } {
            for i in 0...4 {
                amplifiers[i].inputs.append(nextInput)
                if let next = amplifiers[i].runProgramUntilNextOutput() {
                    nextInput = next
                } else {
                    // an amplifer halted; we are done
                    break
                }
            }
        }
        return nextInput
    }.max()!

    print("Part 2: \(maxSignal2)")
}
