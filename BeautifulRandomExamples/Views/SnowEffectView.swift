import SwiftUI
import BeautifulRandom

struct SnowEffectView: View {
    @State private var snowflakes: [SnowGenerator.Snowflake] = []
    @State private var totalTime: Double = 0
    @State private var isSnowing = true

    // 控制参数
    @State private var snowflakeCount: Double = 50
    @State private var minSize: Double = 2
    @State private var maxSize: Double = 8
    @State private var minSpeed: Double = 1
    @State private var maxSpeed: Double = 5

    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    private let screenSize = UIScreen.main.bounds.size

    var body: some View {
        ZStack {
            // 背景
            Color.black
                .edgesIgnoringSafeArea(.all)

            // 雪花
            ForEach(Array(snowflakes.enumerated()), id: \.offset) { index, snowflake in
                SnowflakeView(snowflake: snowflake, generator: snowGenerator)
                    .position(snowflake.position)
                    .opacity(snowflake.opacity)
                    .rotationEffect(.radians(snowflake.rotation))
            }

            // 控制面板
            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("下雪", isOn: $isSnowing)
                        .onChange(of: isSnowing) { newValue in
                            if newValue && snowflakes.isEmpty {
                                resetSnowflakes()
                            }
                        }

                    Text("雪花数量: \(Int(snowflakeCount))")
                    Slider(value: $snowflakeCount, in: 10...200, step: 10)
                        .onChange(of: snowflakeCount) { _ in
                            resetSnowflakes()
                        }

                    Text("雪花大小: \(minSize, specifier: "%.1f") - \(maxSize, specifier: "%.1f")")
                    HStack {
                        Slider(value: $minSize, in: 1...5, step: 0.5)
                        Slider(value: $maxSize, in: 5...15, step: 0.5)
                    }
                    .onChange(of: minSize) { _ in resetSnowflakes() }
                    .onChange(of: maxSize) { _ in resetSnowflakes() }

                    Text("下落速度: \(minSpeed, specifier: "%.1f") - \(maxSpeed, specifier: "%.1f")")
                    HStack {
                        Slider(value: $minSpeed, in: 0.5...3, step: 0.5)
                        Slider(value: $maxSpeed, in: 3...10, step: 0.5)
                    }
                    .onChange(of: minSpeed) { _ in resetSnowflakes() }
                    .onChange(of: maxSpeed) { _ in resetSnowflakes() }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding()
            }
        }
        .onAppear {
            resetSnowflakes()
        }
        .onReceive(timer) { _ in
            guard isSnowing else { return }

            // 更新总时间
            totalTime += 0.016

            // 更新雪花位置
            snowflakes = snowGenerator.updateSnowflakes(snowflakes, deltaTime: 0.016, totalTime: totalTime)
        }
    }

    // 雪花生成器
    private var snowGenerator: SnowGenerator {
        SnowGenerator(
            area: CGSize(width: screenSize.width, height: screenSize.height),
            minSize: minSize,
            maxSize: maxSize,
            minSpeed: minSpeed,
            maxSpeed: maxSpeed
        )
    }

    // 重置雪花
    private func resetSnowflakes() {
        snowflakes = snowGenerator.generateSnowflakes(count: Int(snowflakeCount))
    }
}

// 雪花视图组件
struct SnowflakeView: View {
    let snowflake: SnowGenerator.Snowflake
    let generator: SnowGenerator

    var body: some View {
        Canvas { context, size in
            // 获取雪花路径
            let path = generator.createSnowflakePath(for: snowflake)

            // 设置绘制状态
            context.stroke(
                Path(path),
                with: .color(Color.white),
                lineWidth: 1
            )

            context.fill(
                Path(path),
                with: .color(Color.white.opacity(0.8))
            )
        }
        // 修复：确保尺寸始终为正数，避免无效帧尺寸错误
        .frame(width: max(1, snowflake.size * 2), height: max(1, snowflake.size * 2))
        .blur(radius: 0.3)
    }
}
