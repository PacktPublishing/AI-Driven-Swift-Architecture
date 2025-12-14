import SwiftUI
import Combine

// MARK: - Constants
private enum GameConfig {
    static let circleSize: CGFloat = 80
    static let padding: CGFloat = 16 // explicit padding used in layout and position math
    static let scoreIncrement: Int = 1
    static let initialPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
}

// MARK: - Game State
final class GameState: ObservableObject {
    @Published private(set) var score: Int = 0
    @Published private(set) var circlePosition: CGPoint? // optional to avoid layout flicker

    init(initialPosition: CGPoint? = nil) {
        self.circlePosition = initialPosition
    }

    func incrementScore() {
        score += GameConfig.scoreIncrement
    }

    func updatePosition(in bounds: CGRect) {
        // keep the circle fully inside the given bounds (bounds are local to the play area)
        // use top-left origin for placement: x in 0..(width - circleSize)
        guard bounds.width > GameConfig.circleSize, bounds.height > GameConfig.circleSize else {
            // center the circle (top-left) if bounds too small
            circlePosition = CGPoint(x: bounds.midX - GameConfig.circleSize / 2,
                                     y: bounds.midY - GameConfig.circleSize / 2)
            #if DEBUG
            print("updatePosition: bounds too small, top-left -> \(circlePosition!)")
            #endif
            return
        }

        let maxX = bounds.width - GameConfig.circleSize
        let maxY = bounds.height - GameConfig.circleSize
        let x = CGFloat.random(in: 0...maxX)
        let y = CGFloat.random(in: 0...maxY)
        circlePosition = CGPoint(x: x, y: y) // top-left origin
        #if DEBUG
        print("updatePosition: bounds=\(bounds) -> top-left pos=\(circlePosition!)")
        #endif
    }
}

// MARK: - Game View
struct GameView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        GeometryReader { geometry in
            // compute inner size after padding so coordinates align with the ZStack frame
            let pad = GameConfig.padding
            let innerWidth = max(0, geometry.size.width - pad * 2)
            let innerHeight = max(0, geometry.size.height - pad * 2)
            let playHeight = innerHeight * 0.6
            let playRect = CGRect(x: 0, y: 0, width: innerWidth, height: playHeight)

            VStack(spacing: 50) {
                Text("Score: \(gameState.score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                ZStack(alignment: .topLeading) {
                    // background and an inner GeometryReader that gives exact play-area size
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: innerWidth, height: playHeight)

                    GeometryReader { playGeo in
                        let bounds = CGRect(origin: .zero, size: playGeo.size)

                        // ensure initial placement and respond to size changes
                        Color.clear
                            .onAppear { gameState.updatePosition(in: bounds) }
                            .onChange(of: playGeo.size) { _ in gameState.updatePosition(in: bounds) }

                        if let pos = gameState.circlePosition {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: GameConfig.circleSize, height: GameConfig.circleSize)
                                .offset(x: pos.x, y: pos.y) // place using top-left origin
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        gameState.incrementScore()
                                        gameState.updatePosition(in: bounds)
                                    }
                                }
                        }
                    }
                    .frame(width: innerWidth, height: playHeight)
                }
                .clipped()

                Spacer()
            }
            .padding(pad)
            // outer geometry changes are handled by inner GeometryReader; avoid duplicate updates here
         }
     }
 }

 #Preview {
     GameView()
 }
