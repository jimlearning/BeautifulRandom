//
//  ContentView.swift
//  BeautifulRandomExamples
//
//  Created by Jim Learning on 2025/3/9.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Audio Visualizer") {
                    AudioVisualizerView()
                }
                NavigationLink("Radar Scanner") {
                    RadarView()
                }
            }
            .navigationTitle("Beautiful Random")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
