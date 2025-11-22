import Foundation

public struct SeededRandomNumberGenerator: RandomNumberGenerator {
    // Simple LCG for deterministic sequences; not cryptographically secure.
    private var state: UInt64

    public init(seed: Int) {
        // Make sure seed is non-zero to avoid degeneracy.
        self.state = UInt64(bitPattern: Int64(seed == 0 ? 1 : seed))
    }

    public mutating func next() -> UInt64 {
        // Constants from Numerical Recipes
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}
