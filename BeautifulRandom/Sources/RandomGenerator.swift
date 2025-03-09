import Foundation

public enum RandomType {
    case linear          // 线性随机
    case wave           // 波形随机
    case gaussian       // 高斯分布随机
    case perlin         // 柏林噪声
    case bezier         // 贝塞尔曲线随机
}

public class RandomGenerator {
    private var type: RandomType
    private var seed: UInt64

    public init(type: RandomType, seed: UInt64 = UInt64(Date().timeIntervalSince1970)) {
        self.type = type
        self.seed = seed
    }

    public func next() -> Double {
        switch type {
        case .linear:
            return generateLinearRandom()
        case .wave:
            return generateWaveRandom()
        case .gaussian:
            return generateGaussianRandom()
        case .perlin:
            return generatePerlinNoise()
        case .bezier:
            return generateBezierRandom()
        }
    }

    // 基础线性随机，生成的值的范围是 0 到 1 之间的浮点数（包括 0，但不包括 1）
    private func generateLinearRandom() -> Double {
        seed = 6364136223846793005 &* seed &+ 1
        return Double(seed) / Double(UInt64.max)
    }

    // 波形随机
    private func generateWaveRandom() -> Double {
        let t = Double(Date().timeIntervalSince1970)
        return sin(t) * 0.5 + generateLinearRandom() * 0.5
    }

    // 高斯分布随机
    private func generateGaussianRandom() -> Double {
        var v1, v2, s: Double
        repeat {
            v1 = 2 * generateLinearRandom() - 1
            v2 = 2 * generateLinearRandom() - 1
            s = v1 * v1 + v2 * v2
        } while s >= 1 || s == 0

        return v1 * sqrt(-2 * log(s) / s)
    }

    // 柏林噪声
    private func generatePerlinNoise() -> Double {
        // 简化版柏林噪声实现
        let t = Double(Date().timeIntervalSince1970)
        return (sin(t) + sin(2.2 * t + 5.52) + sin(2.9 * t + 0.93) + sin(4.6 * t + 8.94)) / 4.0
    }

    // 贝塞尔曲线随机
    private func generateBezierRandom() -> Double {
        let t = generateLinearRandom()
        return 3 * pow(1 - t, 2) * t + 3 * (1 - t) * pow(t, 2) + pow(t, 3)
    }
}
