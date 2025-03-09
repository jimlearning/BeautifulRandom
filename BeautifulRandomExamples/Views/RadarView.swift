import SwiftUI
import BeautifulRandom

struct RadarView: View {
    @State private var points: [RadarScanner.POI] = []
    @State private var rotation: Double = 0
    @State private var scannerLine: Double = 0
    @State private var previousAngle: Double = 0

    private let scanner = RadarScanner(maxDistance: 150)
    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 雷达背景
            Circle()
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                .background(
                    Circle()
                        .fill(Color.black)
                )

            // 雷达网格
            ForEach(1...3, id: \.self) { ring in
                Circle()
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    .scaleEffect(Double(ring) / 4.0)
            }

            // 十字线
            Rectangle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 1, height: 300)
            Rectangle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 300, height: 1)

            // 扫描线 - 使用完全不同的实现方式
            ZStack {
                // 使用半透明扇形
                Path { path in
                    path.move(to: CGPoint(x: 150, y: 150))
                    path.addArc(center: CGPoint(x: 150, y: 150),
                                radius: 150,
                                startAngle: .degrees(0),
                                endAngle: .degrees(120),
                                clockwise: false)
                    path.closeSubpath()
                }
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.green.opacity(0.6), .green.opacity(0)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .rotationEffect(.degrees(scannerLine))
                .blendMode(.screen)
            }

            // POI 点
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                Circle()
                    .fill(Color.green)
                    .frame(width: 4 + point.intensity * 4, height: 4 + point.intensity * 4)
                    .position(
                        x: 150 + cos(point.angle * .pi / 180) * point.distance,
                        y: 150 + sin(point.angle * .pi / 180) * point.distance
                    )
                    .opacity(point.intensity)
                    .blur(radius: 1)
                    .animation(.easeOut(duration: 0.5), value: point.intensity)
            }
        }
        .frame(width: 300, height: 300)
        .onReceive(timer) { _ in
            // 旋转扫描线 - 使用更平滑的动画
            withAnimation(.linear(duration: 0.03)) {
                // 增加更小的增量，使动画更平滑
                scannerLine += 1.5
            }

            // 当扫描线经过某个区域时，生成新的点
            if Int(scannerLine) % 30 == 0 {
                withAnimation {
                    let newPoints = scanner.scan()
                    let currentAngle = scannerLine.truncatingRemainder(dividingBy: 360)
                    let filteredPoints = newPoints.map { poi in
                        let adjustedAngle = (currentAngle + Double(scanner.generator.next() * 40 - 20)).truncatingRemainder(dividingBy: 360)
                        return RadarScanner.POI(
                            distance: poi.distance,
                            angle: adjustedAngle,
                            intensity: poi.intensity
                        )
                    }
                    points = Array(Array(points + filteredPoints)
                        .filter { $0.intensity > 0.3 }
                        .prefix(20))
                }
            }
        }
    }
}
