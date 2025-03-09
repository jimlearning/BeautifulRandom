//
//  ContentView.swift
//  BeautifulRandomExamples
//
//  Created by Jim Learning on 2025/3/9.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("音频可视化", destination: AudioVisualizerView())
                NavigationLink("雷达扫描", destination: RadarView())
                NavigationLink("雪花效果", destination: SnowEffectView())
                NavigationLink("雨滴效果", destination: RainEffectView())
            }
            .navigationTitle("BeautifulRandom 示例")
        }
    }
}

#Preview {
    ContentView()
}
