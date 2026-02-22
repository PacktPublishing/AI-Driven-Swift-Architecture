//
//  GridView.swift
//  GameOfLife
//
//  Created by Packt
//

import SwiftUI

/// A high-performance view that renders the Game of Life grid using SwiftUI Canvas.
struct GridView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let engine: GameEngine
    let cellSize: CGFloat
    let spacing: CGFloat = 1
    
    /// Adaptive colors based on color scheme
    private var deadColor: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.9)
    }
    
    private var aliveColor: Color {
        colorScheme == .dark ? Color.green : Color.green
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(white: 0.95)
    }
    
    var body: some View {
        let totalSize = CGFloat(engine.gridSize) * (cellSize + spacing)
        
        Canvas { context, size in
            for row in 0..<engine.gridSize {
                for col in 0..<engine.gridSize {
                    let x = CGFloat(col) * (cellSize + spacing)
                    let y = CGFloat(row) * (cellSize + spacing)
                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                    
                    let isAlive = engine.grid[row][col]
                    let cellColor = isAlive ? aliveColor : deadColor
                    
                    let path = RoundedRectangle(cornerRadius: cellSize * 0.15)
                        .path(in: rect)
                    context.fill(path, with: .color(cellColor))
                }
            }
        }
        .frame(width: totalSize, height: totalSize)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    handleTap(at: value.location)
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    handleTap(at: value.location)
                }
        )
    }
    
    /// Converts a touch location to grid coordinates and toggles the corresponding cell.
    ///
    /// Calculates which cell was touched based on the cell size and spacing,
    /// then toggles that cell in the game engine. On iOS, provides haptic feedback.
    ///
    /// - Parameter location: The touch location in the view's coordinate space.
    private func handleTap(at location: CGPoint) {
        let col = Int(location.x / (cellSize + spacing))
        let row = Int(location.y / (cellSize + spacing))
        
        if row >= 0, row < engine.gridSize, col >= 0, col < engine.gridSize {
            engine.toggle(row: row, col: col)
            
            #if os(iOS)
            // Haptic feedback on iOS
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
        }
    }
}

#Preview {
    let engine = GameEngine(gridSize: 30)
    engine.randomize()
    return GridView(engine: engine, cellSize: 12)
        .padding()
}
