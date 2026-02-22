//
//  GameOfLifeApp.swift
//  GameOfLife
//
//  Created by Packt
//

import SwiftUI

/// The main entry point for the Game of Life application.
///
/// This app implements Conway's Game of Life, a cellular automaton where cells
/// on a grid live or die based on simple rules, creating complex emergent patterns.
///
/// ## Features
/// - Interactive grid for toggling cells
/// - Play/pause simulation with adjustable speed
/// - Preset patterns (Glider, Pulsar, Spaceship, etc.)
/// - Responsive layout for portrait and landscape orientations
@main
struct GameOfLifeApp: App {
    /// The main scene containing the game interface.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
