import Foundation

public class RadarScanner {
    public let generator: RandomGenerator
    private let maxDistance: Double

    public init(maxDistance: Double = 1000) {
        self.generator = RandomGenerator(type: .gaussian)
        self.maxDistance = maxDistance
    }

    public struct POI {
        public let distance: Double
        public let angle: Double
        public let intensity: Double

        public init(distance: Double, angle: Double, intensity: Double) {
            self.distance = distance
            self.angle = angle
            self.intensity = intensity
        }
    }

    public func scan() -> [POI] {
        // Ensure count is at least 1 to avoid empty range error
        let count = max(1, Int(generator.next() * 10))
        var points = [POI]()

        for _ in 0..<count {
            let distance = generator.next() * maxDistance
            let angle = generator.next() * 360
            let intensity = generator.next()
            points.append(POI(distance: distance, angle: angle, intensity: intensity))
        }

        return points
    }
}
