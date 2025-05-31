//
//  YWWelcomeView.swift
//  portfolio-manager-app
//
//  Created by Georgi Kamenov on 31.05.25.
import UIKit
import SwiftUI

struct YWWelcomeView : View {
    @AppStorage("hasSeenWelcomeScreen") var hasSeenWelcomeScreen: Bool = false
    var body: some View {
        VStack {
            Spacer()
            Text(UIApplication.appName)
                .font(.largeTitle)
                .fontWeight(.bold)
            YWWelcomeAnimationView()
                .padding()
            Text("AppSlogan")
            Spacer()
            Button {
                hasSeenWelcomeScreen = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, maxHeight: 44)
            }.buttonStyle(.borderedProminent)
            .padding(.horizontal, 50)
            Spacer()
        }
    }
}

#if !SKIP
struct YWWelcomeAnimationView: View {
    @State private var drawProgress: CGFloat = 0

    private let points: [CGFloat] = [0.3, 0.36, 0.55, 0.33, 0.26, 0.15, 0.30, 0.47, 0.55, 0.6, 0.8]
    private let chartSize = CGSize(width: 300, height: 160)
    
    var body: some View {
        ZStack {
            YWChartBackground(size: chartSize, rows: 5, cols: 6)

            GeometryReader { geo in
                let rect = geo.frame(in: .local)

                ZStack {
                    // Trailing glow line (ghosted)
                    YWStockLineShape(points: points, progress: max(drawProgress - 0.05, 0))
                        .stroke(
                            LinearGradient(colors: [.clear, Color.green.opacity(0.2)],
                                           startPoint: .leading,
                                           endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                        )

                    // Main animated line
                    YWStockLineShape(points: points, progress: drawProgress)
                        .stroke(
                            LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: .green.opacity(0.4), radius: 4)

                    // Head dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .modifier(YWMovingDot(points: points, progress: drawProgress, rect: rect, shadowRadius: 12))
                }
            }
            .padding()
        }
        .frame(width: chartSize.width, height: chartSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            withAnimation(.easeOut(duration: 2.5)) {
                drawProgress = 1
            }
        }
    }
}

// MARK: - Enhanced Chart Background

fileprivate struct YWChartBackground: View {
    let size: CGSize
    let rows: Int
    let cols: Int

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(#colorLiteral(red: 0.05, green: 0.1, blue: 0.15, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Grid lines
            ForEach(0..<rows, id: \.self) { i in
                let y = size.height * CGFloat(i) / CGFloat(rows - 1)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }

            ForEach(0..<cols, id: \.self) { i in
                let x = size.width * CGFloat(i) / CGFloat(cols - 1)
                Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }

            // Diagonal light sheen
            LinearGradient(
                gradient: Gradient(colors: [.clear, Color.white.opacity(0.03)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Line Shape

fileprivate struct YWStockLineShape: Shape {
    let points: [CGFloat]
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }

        let total = points.count - 1
        let scaled = progress * CGFloat(total)
        let currentIndex = Int(scaled)
        let t = scaled - CGFloat(currentIndex)

        func point(at index: Int) -> CGPoint {
            let clamped = min(index, total)
            let x = rect.width * CGFloat(clamped) / CGFloat(total)
            let y = rect.height * (1 - points[clamped])
            return CGPoint(x: x, y: y)
        }

        var path = Path()
        path.move(to: point(at: 0))

        for i in 0...currentIndex {
            path.addLine(to: point(at: i))
        }

        if currentIndex < total {
            let start = point(at: currentIndex)
            let end = point(at: currentIndex + 1)
            let interp = CGPoint(
                x: start.x + (end.x - start.x) * t,
                y: start.y + (end.y - start.y) * t
            )
            path.addLine(to: interp)
        }

        return path
    }
}

// MARK: - Dot Modifier

fileprivate struct YWMovingDot: AnimatableModifier {
    let points: [CGFloat]
    var progress: CGFloat
    let rect: CGRect
    let shadowRadius: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let total = points.count - 1
        let scaled = progress * CGFloat(total)
        let currentIndex = Int(scaled)
        let t = scaled - CGFloat(currentIndex)

        func point(at index: Int) -> CGPoint {
            let clamped = min(index, total)
            let x = rect.width * CGFloat(clamped) / CGFloat(total)
            let y = rect.height * (1 - points[clamped])
            return CGPoint(x: x, y: y)
        }

        let head: CGPoint = {
            if currentIndex < total {
                let start = point(at: currentIndex)
                let end = point(at: currentIndex + 1)
                return CGPoint(
                    x: start.x + (end.x - start.x) * t,
                    y: start.y + (end.y - start.y) * t
                )
            } else {
                return point(at: total)
            }
        }()

        return content
            .position(head)
            .shadow(color: .green.opacity(0.8), radius: shadowRadius)
    }
}

#else

struct YWWelcomeAnimationView: View {
    @State private var drawProgress: CGFloat = 0

    let points: [CGFloat] = [0.3, 0.36, 0.55, 0.33, 0.26, 0.15, 0.30, 0.47, 0.55, 0.6, 0.8]

    var body: some View {
        StockLineDrawable(points: points)
            .stroke(Color.green, lineWidth: 3)
            .frame(width: 300, height: 150)
            .padding()
            .onAppear {
                withAnimation(.linear(duration: 3)) {
                    drawProgress = 1
                }
            }
    }

    struct StockLineDrawable: Shape {
        let points: [CGFloat]

        func path(in rect: CGRect) -> Path {
            guard points.count > 1 else { return Path() }

            var path = Path()

            let total = points.count - 1
            let scaledProgress = CGFloat(total)
            let currentIndex = Int(scaledProgress)
            let t = scaledProgress - CGFloat(currentIndex)

            func point(at index: Int) -> CGPoint {
                let clampedIndex = min(index, total)
                let x = rect.width * CGFloat(clampedIndex) / CGFloat(total)
                let y = rect.height * (1 - points[clampedIndex])
                return CGPoint(x: x, y: y)
            }

            path.move(to: point(at: 0))

            for i in 0...currentIndex {
                path.addLine(to: point(at: i))
            }

            if currentIndex < total {
                let start = point(at: currentIndex)
                let end = point(at: currentIndex + 1)
                let interpX = start.x + (end.x - start.x) * t
                let interpY = start.y + (end.y - start.y) * t
                path.addLine(to: CGPoint(x: interpX, y: interpY))
            }

            return path
        }
    }
}
#endif
