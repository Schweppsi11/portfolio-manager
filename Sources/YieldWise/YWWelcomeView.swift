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
            Text(UIApplication.appName)
                .font(.largeTitle)
            YWWelcomeAnimationView()
            Text("AppSlogan")
            Button {
                hasSeenWelcomeScreen = true
            } label: {
                Text("Get Started")
            }.buttonStyle(.borderedProminent)

        }
    }
}

struct YWWelcomeAnimationView: View {
    @State private var drawProgress: CGFloat = 0

    let points: [CGFloat] = [0.3, 0.36, 0.55, 0.33, 0.26, 0.15, 0.30, 0.47, 0.55, 0.6, 0.8]

    var body: some View {
        StockLineDrawable(points: points, progress: drawProgress)
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
        var progress: CGFloat

        var animatableData: CGFloat {
            get { progress }
            set { progress = newValue }
        }

        func path(in rect: CGRect) -> Path {
            guard points.count > 1 else { return Path() }

            var path = Path()

            let total = points.count - 1
            let scaledProgress = progress * CGFloat(total)
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

