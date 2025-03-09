import SwiftUI
import BeautifulRandom

struct AudioVisualizerView: View {
    @State private var bars: [Double] = []
    @State private var targetBars: [Double] = []
    private let visualizer = AudioVisualizer(barCount: 30)
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let baseHeight: Double = 0.3

    // 关键是使用固定的容器高度，并从底部对齐
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, height in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 8, height: height * 200)
            }
        }
        .frame(height: 200, alignment: .bottom) // 关键：固定容器高度并从底部对齐
        .background(Color.black.opacity(0.1))
        .onAppear {
            bars = visualizer.generateBars().map { max($0, baseHeight) }
            targetBars = bars
        }
        .onReceive(timer) { _ in
            targetBars = visualizer.generateBars().map { max($0, baseHeight) }

            withAnimation(.linear(duration: 0.05)) {
                for i in 0..<bars.count {
                    let diff = targetBars[i] - bars[i]
                    bars[i] += diff * 0.2
                }
            }
        }
    }
}
