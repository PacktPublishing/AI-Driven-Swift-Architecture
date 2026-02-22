//
//  ControlsView.swift
//  GameOfLife
//
//  Created by Packt
//

import SwiftUI

/// A view that provides user controls for the Game of Life simulation.
///
/// `ControlsView` contains all interactive elements for controlling the simulation:
/// - Statistics display (generation count, living cells)
/// - Playback controls (play/pause, step, randomize, clear)
/// - Speed adjustment slider
/// - Preset pattern selection
///
/// ## Usage
/// ```swift
/// ControlsView(engine: gameEngine)
/// ```
struct ControlsView: View {
    /// The game engine to control. Uses `@Bindable` to enable two-way binding
    /// for properties like `speed` and `isRunning`.
    @Bindable var engine: GameEngine
    
    var body: some View {
        VStack(spacing: 20) {
            // Stats display
            StatsView(generation: engine.generation, livingCells: engine.livingCells)
            
            // Playback controls
            PlaybackControls(engine: engine)
            
            // Speed control
            SpeedControl(speed: $engine.speed)
            
            // Pattern selector
            PatternSelector(engine: engine)
        }
        .padding()
    }
}

/// Displays the current simulation statistics.
///
/// Shows the generation counter and living cell count in a horizontal layout
/// with monospaced font for consistent number alignment.
private struct StatsView: View {
    /// The current generation number.
    let generation: Int
    
    /// The number of cells currently alive on the grid.
    let livingCells: Int
    
    var body: some View {
        HStack(spacing: 30) {
            StatItem(title: "Generation", value: "\(generation)")
            StatItem(title: "Living Cells", value: "\(livingCells)")
        }
        .font(.system(.body, design: .monospaced))
    }
}

/// A single statistic display item with a title and value.
private struct StatItem: View {
    /// The label describing the statistic.
    let title: String
    
    /// The formatted value to display.
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
    }
}

/// Provides playback control buttons for the simulation.
///
/// Includes buttons for:
/// - **Play/Pause**: Toggle automatic simulation advancement
/// - **Step**: Manually advance one generation (disabled while running)
/// - **Randomize**: Fill the grid with random cells
/// - **Clear**: Reset the grid to empty state
private struct PlaybackControls: View {
    /// The game engine to control.
    @Bindable var engine: GameEngine
    
    var body: some View {
        HStack(spacing: 16) {
            // Play/Pause button
            Button {
                engine.isRunning.toggle()
            } label: {
                Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(engine.isRunning ? Color.orange : Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            // Step button
            Button {
                engine.step()
            } label: {
                Image(systemName: "forward.frame.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(engine.isRunning)
            .opacity(engine.isRunning ? 0.5 : 1)
            
            // Randomize button
            Button {
                engine.randomize()
            } label: {
                Image(systemName: "dice.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            // Clear button
            Button {
                engine.clear()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

/// A slider control for adjusting the simulation speed.
///
/// Allows the user to set the speed from 1 to 20 generations per second.
/// Visual indicators (tortoise and hare icons) help communicate the speed range.
private struct SpeedControl: View {
    /// Binding to the simulation speed in generations per second.
    @Binding var speed: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "tortoise.fill")
                    .foregroundStyle(.secondary)
                Slider(value: $speed, in: 1...20, step: 1)
                    .tint(.green)
                Image(systemName: "hare.fill")
                    .foregroundStyle(.secondary)
            }
            Text("\(Int(speed)) gen/sec")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// A horizontally scrolling selector for loading preset patterns.
///
/// Displays all available patterns from the `Pattern` enum as tappable buttons.
/// When selected, the pattern is loaded centered on the grid.
private struct PatternSelector: View {
    /// The game engine to load patterns into.
    let engine: GameEngine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Patterns")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Pattern.allCases) { pattern in
                        Button {
                            engine.loadPattern(pattern)
                        } label: {
                            Text(pattern.rawValue)
                                .font(.subheadline.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.green.opacity(0.2))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview("Dark Mode") {
    ControlsView(engine: GameEngine())
        .frame(width: 350)
        .preferredColorScheme(.dark)
}
#Preview("Light Mode") {
    ControlsView(engine: GameEngine())
        .frame(width: 350)
        .preferredColorScheme(.light)
}

