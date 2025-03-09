import Foundation
import CoreGraphics

public class RadarScanner {
    // 随机数生成器
    public let generator: RandomGenerator

    // 基本参数
    private let maxDistance: Double
    private let center: CGPoint

    // 控制参数
    public var constrainToCircle: Bool = true
    public var constrainToScanSector: Bool = true
    private var currentScanAngle: Double = 0
    private var scanSectorWidth: Double = 60 // 扫描扇区宽度，默认60度

    // 初始化方法
    public init(maxDistance: Double = 1000, center: CGPoint = CGPoint(x: 0, y: 0)) {
        self.generator = RandomGenerator(type: .gaussian)
        self.maxDistance = maxDistance
        self.center = center
    }

    // POI 结构体
    public struct POI {
        public let distance: Double
        public let angle: Double
        public let intensity: Double

        public init(distance: Double, angle: Double, intensity: Double) {
            self.distance = distance
            self.angle = angle
            self.intensity = intensity
        }

        // 转换为 CGPoint
        public func toCGPoint(center: CGPoint = .zero) -> CGPoint {
            let x = center.x + cos(angle * .pi / 180) * distance
            let y = center.y + sin(angle * .pi / 180) * distance
            return CGPoint(x: x, y: y)
        }
    }

    // 更新当前扫描角度
    public func updateScanAngle(_ angle: Double) {
        currentScanAngle = normalizeAngle(angle)
    }

    // 设置扫描扇区宽度
    public func setScanSectorWidth(_ width: Double) {
        scanSectorWidth = max(10, min(180, width)) // 限制在10-180度之间
    }

    // 标准化角度到0-360范围
    private func normalizeAngle(_ angle: Double) -> Double {
        var normalized = angle.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }
        return normalized
    }

    // 生成POI点
    public func scanPOIs(atAngle angle: Double? = nil, count: Int? = nil) -> [POI] {
        let pointCount = count ?? max(1, Int(abs(generator.next() * 5)) + 1)
        let scanAngle = angle != nil ? normalizeAngle(angle!) : currentScanAngle
        var points = [POI]()

        for _ in 0..<pointCount {
            if let point = generateValidPOI(scanAngle: scanAngle) {
                points.append(point)
            }
        }

        return points
    }

    // 生成CGPoint点
    public func scanCGPoints(atAngle angle: Double? = nil, count: Int? = nil) -> [CGPoint] {
        let pois = scanPOIs(atAngle: angle, count: count)
        return pois.map { $0.toCGPoint(center: center) }
    }

    // 生成单个有效的POI点
    private func generateValidPOI(scanAngle: Double) -> POI? {
        // 最大尝试次数，防止无限循环
        let maxAttempts = 1
        var attempts = 0

        while attempts < maxAttempts {
            attempts += 1

            // 生成随机强度 (0.3-1.0)
            let intensity = 0.3 + abs(generator.next() * 0.7)

            // 生成随机距离
            var distance: Double
            if constrainToCircle {
                // 使用平方根分布确保点在圆内均匀分布
                let r = sqrt(abs(generator.next()))
                distance = r * maxDistance
            } else {
                distance = abs(generator.next() * maxDistance)
            }

            // 生成随机角度
            var angle: Double
            if constrainToScanSector {
                // 计算扇区范围
                let halfWidth = scanSectorWidth / 2
                let sectorStart = normalizeAngle(scanAngle - halfWidth)
                let sectorEnd = normalizeAngle(scanAngle + halfWidth)

                // 生成扇区内的角度
                if sectorStart > sectorEnd { // 扇区跨越0度
                    if abs(generator.next()) < 0.5 {
                        // 第一部分 (sectorStart到360)
                        angle = sectorStart + abs(generator.next()) * (360 - sectorStart)
                    } else {
                        // 第二部分 (0到sectorEnd)
                        angle = abs(generator.next()) * sectorEnd
                    }
                } else {
                    // 正常情况
                    angle = sectorStart + abs(generator.next()) * (sectorEnd - sectorStart)
                }
            } else {
                angle = abs(generator.next() * 360)
            }

            // 标准化角度
            angle = normalizeAngle(angle)

            // 验证生成的点是否满足所有限制条件
            if isValidPoint(distance: distance, angle: angle, scanAngle: scanAngle) {
                return POI(distance: distance, angle: angle, intensity: intensity)
            }
        }

        // 如果多次尝试都失败，返回nil
        return nil
    }

    // 验证点是否满足所有限制条件
    private func isValidPoint(distance: Double, angle: Double, scanAngle: Double) -> Bool {
        // 验证距离限制
        if constrainToCircle && distance > maxDistance {
            return false
        }

        // 验证扇区限制
        if constrainToScanSector {
            let halfWidth = scanSectorWidth / 2
            let sectorStart = normalizeAngle(scanAngle - halfWidth)
            let sectorEnd = normalizeAngle(scanAngle + halfWidth)

            if sectorStart > sectorEnd { // 扇区跨越0度
                if !(angle >= sectorStart || angle <= sectorEnd) {
                    return false
                }
            } else {
                if !(angle >= sectorStart && angle <= sectorEnd) {
                    return false
                }
            }
        }

        return true
    }
}
