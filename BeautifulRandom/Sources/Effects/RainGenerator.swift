import Foundation
import CoreGraphics

public class RainGenerator {
    public let generator: RandomGenerator
    private let area: CGSize
    private let minSpeed: Double
    private let maxSpeed: Double
    private let minLength: Double
    private let maxLength: Double

    /// 初始化雨滴生成器
    /// - Parameters:
    ///   - area: 雨滴生成区域大小
    ///   - minSpeed: 最小下落速度
    ///   - maxSpeed: 最大下落速度
    ///   - minLength: 最小雨滴长度
    ///   - maxLength: 最大雨滴长度
    public init(
        area: CGSize,
        minSpeed: Double = 5.0,
        maxSpeed: Double = 15.0,
        minLength: Double = 10.0,
        maxLength: Double = 30.0
    ) {
        self.generator = RandomGenerator(type: .gaussian)
        self.area = area
        self.minSpeed = minSpeed
        self.maxSpeed = maxSpeed
        self.minLength = minLength
        self.maxLength = maxLength
    }

    /// 雨滴数据结构
    public struct Raindrop {
        /// 雨滴位置
        public let position: CGPoint
        /// 雨滴长度
        public let length: Double
        /// 雨滴下落速度
        public let speed: Double
        /// 雨滴透明度
        public let opacity: Double
        /// 雨滴角度（弧度）- 修改为固定垂直向下
        public let angle: Double

        public init(position: CGPoint, length: Double, speed: Double, opacity: Double, angle: Double) {
            self.position = position
            self.length = length
            self.speed = speed
            self.opacity = opacity
            self.angle = angle
        }

        /// 获取雨滴的终点位置
        public func endPoint() -> CGPoint {
            // 确保雨滴垂直向下
            return CGPoint(
                x: position.x,
                y: position.y + length
            )
        }

        /// 根据时间更新雨滴位置
        public func updated(deltaTime: Double) -> Raindrop {
            // 只更新Y坐标，保持X坐标不变，确保垂直下落
            let newY = position.y + speed * deltaTime
            let newPosition = CGPoint(x: position.x, y: newY)
            return Raindrop(
                position: newPosition,
                length: length,
                speed: speed,
                opacity: opacity,
                angle: angle
            )
        }
    }

    /// 生成指定数量的雨滴
    /// - Parameter count: 雨滴数量
    /// - Returns: 雨滴数组
    public func generateRaindrops(count: Int) -> [Raindrop] {
        var raindrops = [Raindrop]()

        for _ in 0..<count {
            let x = generator.next() * area.width
            // 确保雨滴从屏幕顶部或以上开始
            let y = generator.next() * area.height * 0.5 - maxLength
            let position = CGPoint(x: x, y: y)

            let length = minLength + generator.next() * (maxLength - minLength)
            let speed = minSpeed + generator.next() * (maxSpeed - minSpeed)
            let opacity = 0.3 + generator.next() * 0.7

            // 固定雨滴角度为垂直向下 (π/2)
            let angle = CGFloat.pi / 2

            let raindrop = Raindrop(
                position: position,
                length: length,
                speed: speed,
                opacity: opacity,
                angle: angle
            )

            raindrops.append(raindrop)
        }

        return raindrops
    }

    /// 更新雨滴位置
    /// - Parameters:
    ///   - raindrops: 当前雨滴数组
    ///   - deltaTime: 时间间隔
    /// - Returns: 更新后的雨滴数组
    public func updateRaindrops(_ raindrops: [Raindrop], deltaTime: Double) -> [Raindrop] {
        return raindrops.map { raindrop in
            let updated = raindrop.updated(deltaTime: deltaTime)

            // 如果雨滴超出区域底部，将其重置到顶部
            if updated.position.y > area.height {
                let newX = generator.next() * area.width
                // 确保新雨滴从屏幕顶部以上开始
                let newPosition = CGPoint(x: newX, y: -raindrop.length)

                return Raindrop(
                    position: newPosition,
                    length: raindrop.length,
                    speed: raindrop.speed,
                    opacity: raindrop.opacity,
                    angle: raindrop.angle
                )
            }

            return updated
        }
    }
}
