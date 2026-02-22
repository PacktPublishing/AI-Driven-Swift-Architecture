//
//  ContentView.swift
//  GameOfLife
//
//  Created by Packt
//

import SwiftUI

/// Main view composing the Game of Life UI
struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var engine = GameEngine(gridSize: 30)
    @State private var timer: Timer?
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(white: 0.98)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let cellSize = calculateCellSize(for: geometry.size, isLandscape: isLandscape)
            
            Group {
                if isLandscape {
                    HStack(spacing: 20) {
                        gridSection(cellSize: cellSize)
                        controlsSection
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        gridSection(cellSize: cellSize)
                        controlsSection
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .background(backgroundColor)
        .onChange(of: engine.isRunning) { _, isRunning in
            handleRunningStateChange(isRunning)
        }
        .onChange(of: engine.speed) { _, _ in
            // Restart timer with new speed if running
            if engine.isRunning {
                stopTimer()
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    /// Calculate the optimal cell size based on available space
    private func calculateCellSize(for size: CGSize, isLandscape: Bool) -> CGFloat {
        let spacing: CGFloat = 1
        let padding: CGFloat = 40
        
        let availableWidth: CGFloat
        let availableHeight: CGFloat
        
        if isLandscape {
            // In landscape, grid takes left portion
            availableWidth = size.width * 0.55 - padding
            availableHeight = size.height - padding
        } else {
            // In portrait, grid takes top portion
            availableWidth = size.width - padding
            availableHeight = size.height * 0.55 - padding
        }
        
        let gridDimension = CGFloat(engine.gridSize)
        let maxCellWidth = (availableWidth - (gridDimension - 1) * spacing) / gridDimension
        let maxCellHeight = (availableHeight - (gridDimension - 1) * spacing) / gridDimension
        
        return min(maxCellWidth, maxCellHeight, 20) // Cap at 20 for aesthetics
    }
    
    @ViewBuilder
    private func gridSection(cellSize: CGFloat) -> some View {
        VStack(spacing: 12) {
            Text("Game of Life")
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            GridView(engine: engine, cellSize: cellSize)
                .animation(.easeInOut(duration: 0.1), value: engine.grid)
        }
    }
    
    /// The controls section
    private var controlsSection: some View {
        ControlsView(engine: engine)
            .frame(maxWidth: 400)
    }
    
    /// Handle changes to the running state
    private func handleRunningStateChange(_ isRunning: Bool) {
        if isRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    /// Start the simulation timer
    private func startTimer() {
        let interval = 1.0 / engine.speed
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            engine.step()
        }
    }
    
    /// Stop the simulation timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

