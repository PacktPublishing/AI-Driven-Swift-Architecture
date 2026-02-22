//
//  GameEngine.swift
//  GameOfLife
//
//  Created by Packt
//

import Foundation

/// Preset patterns for Conway's Game of Life.
///
/// Each pattern represents a classic cellular automaton configuration with known behavior:
/// - **Oscillators**: Patterns that cycle between states (Blinker, Pulsar, Beacon, Toad)
/// - **Spaceships**: Patterns that translate across the grid (Glider, Spaceship/LWSS)
///
/// ## Usage
/// ```swift
/// engine.loadPattern(.glider)
/// ```
enum Pattern: String, CaseIterable, Identifiable {
    /// A small diagonal spaceship that moves across the grid.
    case glider = "Glider"
    
    /// A simple period-2 oscillator (3 cells in a line).
    case blinker = "Blinker"
    
    /// A large period-3 oscillator with beautiful symmetry.
    case pulsar = "Pulsar"
    
    /// A period-2 oscillator made of two overlapping blocks.
    case beacon = "Beacon"
    
    /// A period-2 oscillator (6 cells).
    case toad = "Toad"
    
    /// Lightweight spaceship - moves horizontally across the grid.
    case lwss = "Spaceship"
    
    var id: String { rawValue }
    
    /// The cell positions that make up this pattern, relative to the top-left corner.
    ///
    /// These coordinates are used by `GameEngine.loadPattern(_:)` to place
    /// the pattern centered on the grid.
    var cells: [(row: Int, col: Int)] {
        switch self {
        case .glider:
            return [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]
        case .blinker:
            return [(0, 0), (0, 1), (0, 2)]
        case .pulsar:
            // Pulsar is a period-3 oscillator
            var positions: [(Int, Int)] = []
            let offsets = [
                (-6, -4), (-6, -3), (-6, -2), (-6, 2), (-6, 3), (-6, 4),
                (-4, -6), (-3, -6), (-2, -6), (-4, 1), (-3, 1), (-2, 1),
                (-4, -1), (-3, -1), (-2, -1), (-4, 6), (-3, 6), (-2, 6),
                (-1, -4), (-1, -3), (-1, -2), (-1, 2), (-1, 3), (-1, 4),
                (1, -4), (1, -3), (1, -2), (1, 2), (1, 3), (1, 4),
                (2, -6), (3, -6), (4, -6), (2, 1), (3, 1), (4, 1),
                (2, -1), (3, -1), (4, -1), (2, 6), (3, 6), (4, 6),
                (6, -4), (6, -3), (6, -2), (6, 2), (6, 3), (6, 4)
            ]
            positions = offsets.map { ($0.0 + 7, $0.1 + 7) }
            return positions
        case .beacon:
            return [(0, 0), (0, 1), (1, 0), (2, 3), (3, 2), (3, 3)]
        case .toad:
            return [(0, 1), (0, 2), (0, 3), (1, 0), (1, 1), (1, 2)]
        case .lwss:
            // Lightweight spaceship
            return [(0, 1), (0, 4), (1, 0), (2, 0), (2, 4), (3, 0), (3, 1), (3, 2), (3, 3)]
        }
    }
}

/// The core simulation engine implementing Conway's Game of Life rules.
///
/// `GameEngine` manages the cellular automaton state and provides methods to:
/// - Advance the simulation step-by-step or continuously
/// - Toggle individual cells for manual editing
/// - Load preset patterns
/// - Randomize or clear the grid
///
/// ## Conway's Game of Life Rules
/// 1. Any live cell with 2 or 3 live neighbors survives
/// 2. Any dead cell with exactly 3 live neighbors becomes alive
/// 3. All other cells die or stay dead
///
/// ## Grid Topology
/// The grid uses toroidal (wrap-around) edges, meaning cells on one edge
/// are neighbors with cells on the opposite edge.
///
/// ## Usage
/// ```swift
/// let engine = GameEngine(gridSize: 30)
/// engine.loadPattern(.glider)
/// engine.step() // Advance one generation
/// ```
@Observable
final class GameEngine {
    /// The 2D grid of cells where `true` represents a living cell and `false` represents a dead cell.
    private(set) var grid: [[Bool]]
    
    /// Indicates whether the simulation is currently running automatically.
    /// When `true`, the UI timer advances the simulation at the configured `speed`.
    var isRunning: Bool = false
    
    /// The current generation number, incremented each time `step()` is called.
    private(set) var generation: Int = 0
    
    /// The number of rows and columns in the square grid.
    let gridSize: Int
    
    /// The simulation speed in generations per second (range: 1-20).
    var speed: Double = 5.0
    
    /// The count of currently living cells on the grid.
    var livingCells: Int {
        grid.flatMap { $0 }.filter { $0 }.count
    }
    
    /// Creates a new game engine with the specified grid size.
    ///
    /// - Parameter gridSize: The number of rows and columns for the square grid. Defaults to 30.
    init(gridSize: Int = 30) {
        self.gridSize = gridSize
        self.grid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
    }
    
    /// Toggles the state of a cell between alive and dead.
    ///
    /// If the cell is alive, it becomes dead. If dead, it becomes alive.
    /// Invalid coordinates are silently ignored.
    ///
    /// - Parameters:
    ///   - row: The row index of the cell (0-based).
    ///   - col: The column index of the cell (0-based).
    func toggle(row: Int, col: Int) {
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else { return }
        grid[row][col].toggle()
    }
    
    /// Advances the simulation by one generation using Conway's rules.
    ///
    /// This method evaluates every cell in the grid and applies the following rules:
    /// - A live cell with 2 or 3 neighbors survives
    /// - A dead cell with exactly 3 neighbors becomes alive
    /// - All other cells die or remain dead
    ///
    /// The generation counter is incremented after each step.
    func step() {
        var newGrid = grid
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let neighbors = countNeighbors(row: row, col: col)
                let isAlive = grid[row][col]
                
                // Apply Conway's Game of Life rules
                if isAlive {
                    // Live cell with 2 or 3 neighbors survives
                    newGrid[row][col] = neighbors == 2 || neighbors == 3
                } else {
                    // Dead cell with exactly 3 neighbors becomes alive
                    newGrid[row][col] = neighbors == 3
                }
            }
        }
        
        grid = newGrid
        generation += 1
    }
    
    /// Counts the number of living neighbors for a cell using toroidal wrapping.
    ///
    /// Examines all 8 adjacent cells (horizontal, vertical, and diagonal).
    /// Edge cells wrap around to the opposite side of the grid.
    ///
    /// - Parameters:
    ///   - row: The row index of the cell.
    ///   - col: The column index of the cell.
    /// - Returns: The count of living neighbors (0-8).
    private func countNeighbors(row: Int, col: Int) -> Int {
        var count = 0
        
        for dRow in -1...1 {
            for dCol in -1...1 {
                // Skip the cell itself
                if dRow == 0 && dCol == 0 { continue }
                
                // Wrap around edges (toroidal grid)
                let neighborRow = (row + dRow + gridSize) % gridSize
                let neighborCol = (col + dCol + gridSize) % gridSize
                
                if grid[neighborRow][neighborCol] {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    /// Clears all cells and resets the simulation state.
    ///
    /// Sets all cells to dead, resets the generation counter to 0,
    /// and stops the simulation if running.
    func clear() {
        grid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        generation = 0
        isRunning = false
    }
    
    /// Fills the grid with random cells.
    ///
    /// Approximately 25% of cells will be alive. The generation counter
    /// is reset to 0, but the simulation running state is preserved.
    func randomize() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                grid[row][col] = Double.random(in: 0...1) < 0.25
            }
        }
        generation = 0
    }
    
    /// Loads a preset pattern centered on the grid.
    ///
    /// Clears the existing grid and places the pattern's cells approximately
    /// in the center. The generation counter is reset to 0.
    ///
    /// - Parameter pattern: The preset pattern to load.
    func loadPattern(_ pattern: Pattern) {
        clear()
        
        // Calculate center offset
        let centerRow = gridSize / 2
        let centerCol = gridSize / 2
        
        for cell in pattern.cells {
            let row = centerRow + cell.row - 2
            let col = centerCol + cell.col - 2
            
            if row >= 0, row < gridSize, col >= 0, col < gridSize {
                grid[row][col] = true
            }
        }
    }
}
