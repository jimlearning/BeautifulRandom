import Foundation
import CoreGraphics

public class SnowGenerator {
    public let generator: RandomGenerator
    private let area: CGSize
    private let minSize: Double
    private let maxSize: Double
    private let minSpeed: Double
    private let maxSpeed: Double

    /// 初始化雪花生成器
    /// - Parameters:
    ///   - area: 雪花生成区域大小
    ///   - minSize: 最小雪花大小
    ///   - maxSize: 最大雪花大小
    ///   - minSpeed: 最小下落速度
    ///   - maxSpeed: 最大下落速度
    public init(
        area: CGSize,
        minSize: Double = 2.0,
        maxSize: Double = 8.0,
        minSpeed: Double = 1.0,
        maxSpeed: Double = 5.0
    ) {
        self.generator = RandomGenerator(type: .gaussian)
        self.area = area
        self.minSize = minSize
        self.maxSize = maxSize
        self.minSpeed = minSpeed
        self.maxSpeed = maxSpeed
    }

    /// 雪花数据结构
    public struct Snowflake {
        /// 雪花位置
        public let position: CGPoint
        /// 雪花大小
        public let size: Double
        /// 雪花下落速度
        public let speed: Double
        /// 雪花透明度
        public let opacity: Double
        /// 雪花旋转角度（弧度）
        public let rotation: Double
        /// 雪花水平摆动幅度
        public let swingAmount: Double
        /// 雪花水平摆动频率
        public let swingFrequency: Double
        /// 雪花初始相位
        public let initialPhase: Double
        /// 雪花形状复杂度 (1-5)
        public let complexity: Int

        public init(
            position: CGPoint,
            size: Double,
            speed: Double,
            opacity: Double,
            rotation: Double,
            swingAmount: Double,
            swingFrequency: Double,
            initialPhase: Double,
            complexity: Int
        ) {
            self.position = position
            self.size = size
            self.speed = speed
            self.opacity = opacity
            self.rotation = rotation
            self.swingAmount = swingAmount
            self.swingFrequency = swingFrequency
            self.initialPhase = initialPhase
            self.complexity = complexity
        }

        /// 根据时间更新雪花位置
        public func updated(deltaTime: Double, totalTime: Double) -> Snowflake {
            // 计算水平摆动
            let phase = initialPhase + totalTime * swingFrequency
            let swingOffset = sin(phase) * swingAmount

            // 更新位置 - 确保雪花主要是向下移动，水平摆动只是轻微的
            let newX = position.x + swingOffset * deltaTime
            let newY = position.y + speed * deltaTime
            let newPosition = CGPoint(x: newX, y: newY)

            // 更新旋转
            let newRotation = rotation + deltaTime * 0.2 * speed

            return Snowflake(
                position: newPosition,
                size: size,
                speed: speed,
                opacity: opacity,
                rotation: newRotation,
                swingAmount: swingAmount,
                swingFrequency: swingFrequency,
                initialPhase: initialPhase,
                complexity: complexity
            )
        }
    }

    /// 生成指定数量的雪花
    /// - Parameter count: 雪花数量
    /// - Returns: 雪花数组
    public func generateSnowflakes(count: Int) -> [Snowflake] {
        var snowflakes = [Snowflake]()

        for _ in 0..<count {
            // 修改初始位置：x 在屏幕宽度范围内随机，y 在屏幕顶部以上
            let x = generator.next() * area.width
            let y = -maxSize - generator.next() * area.height * 0.3 // 从屏幕顶部以上开始
            let position = CGPoint(x: x, y: y)

            let size = minSize + generator.next() * (maxSize - minSize)
            let speed = minSpeed + generator.next() * (maxSpeed - minSpeed)
            let opacity = 0.5 + generator.next() * 0.5
            let rotation = generator.next() * .pi * 2

            // 减小水平摆动幅度，使雪花主要向下落
            let swingAmount = 0.5 + generator.next() * 1.5
            let swingFrequency = 0.2 + generator.next() * 0.8
            let initialPhase = generator.next() * .pi * 2

            // 雪花复杂度 (1-5)
            let complexity = Int(1 + generator.next() * 4)

            let snowflake = Snowflake(
                position: position,
                size: size,
                speed: speed,
                opacity: opacity,
                rotation: rotation,
                swingAmount: swingAmount,
                swingFrequency: swingFrequency,
                initialPhase: initialPhase,
                complexity: complexity
            )

            snowflakes.append(snowflake)
        }

        return snowflakes
    }

    /// 更新雪花位置
    /// - Parameters:
    ///   - snowflakes: 当前雪花数组
    ///   - deltaTime: 时间间隔
    ///   - totalTime: 总经过时间
    /// - Returns: 更新后的雪花数组
    public func updateSnowflakes(_ snowflakes: [Snowflake], deltaTime: Double, totalTime: Double) -> [Snowflake] {
        return snowflakes.map { snowflake in
            let updated = snowflake.updated(deltaTime: deltaTime, totalTime: totalTime)

            // 如果雪花超出区域底部，将其重置到顶部
            if updated.position.y > area.height + snowflake.size {
                let newX = generator.next() * area.width
                let newPosition = CGPoint(x: newX, y: -snowflake.size * 2)

                return Snowflake(
                    position: newPosition,
                    size: snowflake.size,
                    speed: snowflake.speed,
                    opacity: snowflake.opacity,
                    rotation: snowflake.rotation,
                    swingAmount: snowflake.swingAmount,
                    swingFrequency: snowflake.swingFrequency,
                    initialPhase: generator.next() * .pi * 2, // 重置相位
                    complexity: snowflake.complexity
                )
            }

            // 如果雪花超出区域左右边界，将其重置到相对的另一侧
            if updated.position.x < -snowflake.size {
                let newPosition = CGPoint(x: area.width + snowflake.size, y: updated.position.y)
                return Snowflake(
                    position: newPosition,
                    size: snowflake.size,
                    speed: snowflake.speed,
                    opacity: snowflake.opacity,
                    rotation: snowflake.rotation,
                    swingAmount: snowflake.swingAmount,
                    swingFrequency: snowflake.swingFrequency,
                    initialPhase: snowflake.initialPhase,
                    complexity: snowflake.complexity
                )
            } else if updated.position.x > area.width + snowflake.size {
                let newPosition = CGPoint(x: -snowflake.size, y: updated.position.y)
                return Snowflake(
                    position: newPosition,
                    size: snowflake.size,
                    speed: snowflake.speed,
                    opacity: snowflake.opacity,
                    rotation: snowflake.rotation,
                    swingAmount: snowflake.swingAmount,
                    swingFrequency: snowflake.swingFrequency,
                    initialPhase: snowflake.initialPhase,
                    complexity: snowflake.complexity
                )
            }

            return updated
        }
    }

    /// 生成雪花路径
    /// - Parameter snowflake: 雪花对象
    /// - Returns: 雪花形状的路径
    public func createSnowflakePath(for snowflake: Snowflake) -> CGPath {
        let path = CGMutablePath()
        let center = CGPoint(x: 0, y: 0)
        let radius = snowflake.size

        // 根据复杂度生成不同形状的雪花
        switch snowflake.complexity {
        case 1:
            // 简单圆形雪花
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))

        case 2:
            // 六角形雪花
            let sides = 6
            for i in 0..<sides {
                let angle = Double(i) * (2 * .pi / Double(sides))
                let point = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )

                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()

        case 3:
            // 星形雪花
            let points = 8
            let innerRadius = radius * 0.4

            for i in 0..<points * 2 {
                let angle = Double(i) * (.pi / Double(points))
                let useRadius = i % 2 == 0 ? radius : innerRadius
                let point = CGPoint(
                    x: center.x + cos(angle) * useRadius,
                    y: center.y + sin(angle) * useRadius
                )

                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()

        case 4:
            // 十字形雪花
            let armLength = radius
            let armWidth = radius * 0.3

            // 水平臂
            path.addRect(CGRect(x: -armLength, y: -armWidth/2, width: armLength * 2, height: armWidth))

            // 垂直臂
            path.addRect(CGRect(x: -armWidth/2, y: -armLength, width: armWidth, height: armLength * 2))

            // 对角线臂1
            let transform1 = CGAffineTransform(rotationAngle: .pi/4)
            let rect1 = CGRect(x: -armLength, y: -armWidth/2, width: armLength * 2, height: armWidth)
            path.addRect(rect1, transform: transform1)

            // 对角线臂2
            let transform2 = CGAffineTransform(rotationAngle: -.pi/4)
            let rect2 = CGRect(x: -armLength, y: -armWidth/2, width: armLength * 2, height: armWidth)
            path.addRect(rect2, transform: transform2)

        case 5:
            // 复杂雪花
            let branches = 6
            let branchLength = radius
            let subBranchLength = radius * 0.5

            for i in 0..<branches {
                let angle = Double(i) * (2 * .pi / Double(branches))
                let endPoint = CGPoint(
                    x: center.x + cos(angle) * branchLength,
                    y: center.y + sin(angle) * branchLength
                )

                // 主分支
                path.move(to: center)
                path.addLine(to: endPoint)

                // 子分支1
                let subAngle1 = angle + .pi/4
                let subEndPoint1 = CGPoint(
                    x: endPoint.x + cos(subAngle1) * subBranchLength * 0.6,
                    y: endPoint.y + sin(subAngle1) * subBranchLength * 0.6
                )
                path.move(to: CGPoint(
                    x: center.x + cos(angle) * branchLength * 0.6,
                    y: center.y + sin(angle) * branchLength * 0.6
                ))
                path.addLine(to: subEndPoint1)

                // 子分支2
                let subAngle2 = angle - .pi/4
                let subEndPoint2 = CGPoint(
                    x: endPoint.x + cos(subAngle2) * subBranchLength * 0.6,
                    y: endPoint.y + sin(subAngle2) * subBranchLength * 0.6
                )
                path.move(to: CGPoint(
                    x: center.x + cos(angle) * branchLength * 0.6,
                    y: center.y + sin(angle) * branchLength * 0.6
                ))
                path.addLine(to: subEndPoint2)
            }

        default:
            // 默认简单圆形
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        }

        return path
    }
}