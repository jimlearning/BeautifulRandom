import Foundation

public class AudioVisualizer {
    private let generator: RandomGenerator
    private let barCount: Int
    private var lastBars: [Double] = []
    private let baseHeight: Double = 0.3  // 基础高度
    private var phase: Double = 0         // 添加相位控制

    public init(barCount: Int = 20) {
        self.generator = RandomGenerator(type: .wave)
        self.barCount = barCount
        self.lastBars = Array(repeating: baseHeight, count: barCount)
    }

    public func generateBars() -> [Double] {
        var newBars = [Double]()
        phase += 0.1  // 控制波形移动速度

        // 生成基础波形
        for i in 0..<barCount {
            let position = Double(i) / Double(barCount)
            // 使用多个不同频率的正弦波叠加
            let wave1 = sin(phase + position * 6.28) * 0.15
            let wave2 = sin(phase * 0.5 + position * 12.56) * 0.1

            // 基础高度 + 波形变化
            let value = baseHeight + wave1 + wave2
            newBars.append(value)
        }

        // 应用平滑处理
        var smoothedBars = newBars
        for _ in 0...2 { // 多次平滑处理
            for i in 1..<barCount-1 {
                let avg = (smoothedBars[i-1] + smoothedBars[i+1]) / 2
                smoothedBars[i] = smoothedBars[i] * 0.7 + avg * 0.3
            }
        }

        // 确保所有值都在合理范围内
        smoothedBars = smoothedBars.map { max(baseHeight, min(1.0, $0)) }

        lastBars = smoothedBars
        return smoothedBars
    }
}