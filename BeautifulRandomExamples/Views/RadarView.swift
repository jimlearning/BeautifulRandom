import SwiftUI
import BeautifulRandom

struct RadarView: View {
    @State private var points: [RadarScanner.POI] = []
    @State private var scannerLine: Double = 0

    // 控制选项
    @State private var constrainToCircle: Bool = true
    @State private var constrainToScanSector: Bool = true

    private let scanner = RadarScanner(maxDistance: 150, center: CGPoint(x: 150, y: 150))
    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
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

                // 扫描线
                ZStack {
                    // 使用半透明扇形
                    Path { path in
                        path.move(to: CGPoint(x: 150, y: 150))
                        path.addArc(center: CGPoint(x: 150, y: 150),
                                   radius: 150,
                                   startAngle: .degrees(-30),
                                   endAngle: .degrees(30),
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
                            point.toCGPoint(center: CGPoint(x: 150, y: 150))
                        )
                        .opacity(point.intensity)
                        .blur(radius: 1)
                        .animation(.easeOut(duration: 0.5), value: point.intensity)
                }
            }
            .frame(width: 300, height: 300)

            // 控制选项
            VStack(alignment: .leading, spacing: 10) {
                Toggle("限制点在圆形内", isOn: $constrainToCircle)
                    .onChange(of: constrainToCircle) { newValue in
                        scanner.constrainToCircle = newValue
                    }

                Toggle("限制点在扫描扇区内", isOn: $constrainToScanSector)
                    .onChange(of: constrainToScanSector) { newValue in
                        scanner.constrainToScanSector = newValue
                    }
            }
            .padding()
        }
        .onAppear {
            // 初始化扫描器设置
            scanner.constrainToCircle = constrainToCircle
            scanner.constrainToScanSector = constrainToScanSector
            scanner.setScanSectorWidth(60) // 设置扫描扇区宽度为60度
        }
        .onReceive(timer) { _ in
            // 旋转扫描线
            withAnimation(.linear(duration: 0.03)) {
                scannerLine += 1.5
            }

            // 更新扫描器的当前角度
            scanner.updateScanAngle(scannerLine)

            // 当扫描线经过某个区域时，生成新的点
            if Int(scannerLine) % 30 == 0 {
                withAnimation {
                    let currentAngle = scannerLine.truncatingRemainder(dividingBy: 360)

                    // 使用新的 RadarScanner2 生成点
                    let newPoints = scanner.scanPOIs(atAngle: scannerLine.truncatingRemainder(dividingBy: 360))
                    
                    // 验证生成的点
                    for (index, point) in newPoints.enumerated() {
                        print("点 \(index): 距离=\(point.distance), 角度=\(point.angle)°, 强度=\(point.intensity)")

                        // 验证圆形限制
                        if constrainToCircle {
                            let isInCircle = point.distance <= 150
                            print("  圆形限制: \(isInCircle ? "✓" : "✗") (最大距离=150)")
                        }

                        // 验证扇区限制
                        if constrainToScanSector {
                            let halfWidth = 30.0 // 60度扇区的一半
                            let sectorStart = (currentAngle - halfWidth).truncatingRemainder(dividingBy: 360)
                            let sectorEnd = (currentAngle + halfWidth).truncatingRemainder(dividingBy: 360)

                            var isInSector = false
                            if sectorStart < sectorEnd {
                                isInSector = point.angle >= sectorStart && point.angle <= sectorEnd
                            } else {
                                // 处理跨越0度的情况
                                isInSector = point.angle >= sectorStart || point.angle <= sectorEnd
                            }

                            print("  扇区限制: \(isInSector ? "✓" : "✗") (扇区范围=\(sectorStart)°-\(sectorEnd)°)")
                        }
                    }

                    // 添加新点并保持点的数量在限制范围内
                    points = Array(Array(points + newPoints)
                        .filter { $0.intensity > 0.3 }
                        .prefix(20))
                }
            }
        }
    }
}
