import SwiftUI
import BeautifulRandom

struct RainEffectView: View {
    @State private var raindrops: [RainGenerator.Raindrop] = []
    @State private var isRaining = true

    // 控制参数
    @State private var raindropCount: Double = 100
    @State private var minLength: Double = 10
    @State private var maxLength: Double = 30
    // 大幅提高雨滴下降速度
    @State private var minSpeed: Double = 100
    @State private var maxSpeed: Double = 200
    @State private var rainColor = Color.blue.opacity(0.6)

    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    private let screenSize = UIScreen.main.bounds.size

    var body: some View {
        ZStack {
            // 背景 - 深蓝色夜空
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.3), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            // 雨滴
            Canvas { context, size in
                for raindrop in raindrops {
                    // 绘制雨滴线条
                    var path = Path()
                    path.move(to: raindrop.position)
                    path.addLine(to: raindrop.endPoint())

                    context.stroke(
                        path,
                        with: .color(rainColor.opacity(raindrop.opacity)),
                        lineWidth: 1.5
                    )
                }
            }

            // 控制面板
            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("下雨", isOn: $isRaining)
                        .onChange(of: isRaining) { newValue in
                            if newValue && raindrops.isEmpty {
                                resetRaindrops()
                            }
                        }

                    Text("雨滴数量: \(Int(raindropCount))")
                    Slider(value: $raindropCount, in: 50...500, step: 50)
                        .onChange(of: raindropCount) { _ in
                            resetRaindrops()
                        }

                    Text("雨滴长度: \(Int(minLength)) - \(Int(maxLength))")
                    HStack {
                        Slider(value: $minLength, in: 5...20, step: 1)
                        Slider(value: $maxLength, in: 20...50, step: 1)
                    }
                    .onChange(of: minLength) { _ in resetRaindrops() }
                    .onChange(of: maxLength) { _ in resetRaindrops() }

                    Text("下落速度: \(Int(minSpeed)) - \(Int(maxSpeed))")
                    HStack {
                        // 进一步提高速度滑块范围
                        Slider(value: $minSpeed, in: 50...150, step: 10)
                        Slider(value: $maxSpeed, in: 150...300, step: 10)
                    }
                    .onChange(of: minSpeed) { _ in resetRaindrops() }
                    .onChange(of: maxSpeed) { _ in resetRaindrops() }

                    ColorPicker("雨滴颜色", selection: $rainColor)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding()
            }
        }
        .onAppear {
            resetRaindrops()
        }
        .onReceive(timer) { _ in
            guard isRaining else { return }

            // 更新雨滴位置
            raindrops = rainGenerator.updateRaindrops(raindrops, deltaTime: 0.016)
        }
    }

    // 雨滴生成器
    private var rainGenerator: RainGenerator {
        RainGenerator(
            area: CGSize(width: screenSize.width, height: screenSize.height),
            minSpeed: minSpeed,
            maxSpeed: maxSpeed,
            minLength: minLength,
            maxLength: maxLength
        )
    }

    // 重置雨滴
    private func resetRaindrops() {
        raindrops = rainGenerator.generateRaindrops(count: Int(raindropCount))
    }
}