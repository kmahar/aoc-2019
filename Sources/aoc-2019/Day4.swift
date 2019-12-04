/// The elements must be Comparable so we can do equality checks.
extension Array where Element: Comparable {
    /// Returns whether this array is already in sorted order.
    var isSorted: Bool { return self.sorted() == self }

    /// Returns whether the array contains two adjacent identical values.
    var containsPair: Bool {
        return (0..<self.count - 1).contains { idx in
            self[idx] == self[idx + 1]
        }
    }

    // Returns whether the array contains two adjacent identical values that are not part of a larger group of
    // consecutive matching values.
    var containsIsolatedPair: Bool {
        // Iterate from the start to the second-to-last index.
        // We are trying to find a value idx where Array[idx] == Array[idx + 1], and Array[idx - 1] and Array[idx + 2]
        // either don't exist or do not equal Array[idx].
        return (0..<self.count - 1).contains { idx in
            let curr = self[idx]

            // Check whether the current element forms a pair with the next element.
            if curr != self[idx + 1] {
                return false
            }

            // Make sure the current element does *not* match the previous element. If it does we have 3+ in a row.
            // If idx == 0 then we are at the start and there is no previous element.
            if idx > 0 && curr == self[idx - 1] {
                return false
            }

            // Make sure this pair is not followed by a third matching element. If idx > self.count - 2 then there is
            // no following element.
            if idx < self.count - 2 && curr == self[idx + 2] {
                return false
            }

            return true
        }
    }
}

func day4() throws {
    // sorted indicates digits are in increasing order.
    let sortedPasswords = (109165...576723).map { Array(String($0)) }.filter { $0.isSorted }

    let containsAdjacentPair = sortedPasswords.filter { $0.containsPair }
    print("Part 1: \(containsAdjacentPair.count)")

    let containsIsolatedPair = sortedPasswords.filter { $0.containsIsolatedPair }
    print("Part 2: \(containsIsolatedPair.count)")
}
