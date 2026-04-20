import SwiftUI

/// Interactive progress bar with A/B point markers drawn on the track.
struct ProgressBarView: View {
    let position: Double
    let duration: Double
    let pointA: Double?
    let pointB: Double?
    let onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragValue: Double = 0

    private var displayPosition: Double { isDragging ? dragValue : position }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let dur = max(duration, 1) // guard against division by zero before a track is loaded

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 5)

                // A-B region fill
                if let a = pointA, let b = pointB {
                    let ax = (a / dur * w).clamped(to: 0...w)
                    let bx = (b / dur * w).clamped(to: 0...w)
                    Capsule()
                        .fill(Color.blue.opacity(0.35))
                        .frame(width: max(0, bx - ax), height: 5)
                        .offset(x: ax)
                }

                // Progress fill
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(0, (displayPosition / dur * w).clamped(to: 0...w)), height: 5)

                // A marker
                if let a = pointA {
                    markerLine(at: a / dur * w, label: "A", color: .green)
                }

                // B marker
                if let b = pointB {
                    markerLine(at: b / dur * w, label: "B", color: .red)
                }

                // Scrubber handle
                let handleX = (displayPosition / dur * w).clamped(to: 0...w)
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                    .frame(width: isDragging ? 20 : 14, height: isDragging ? 20 : 14)
                    .offset(x: handleX - (isDragging ? 10 : 7))
                    .animation(.spring(duration: 0.15), value: isDragging)
            }
            .frame(height: 36)
            // Without this, GeometryReader/ZStack only hits on visible (non-transparent) pixels
            .contentShape(Rectangle())
            .gesture(
                // minimumDistance: 0 lets a tap-in-place trigger a seek (not just a drag)
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragValue = max(0, min(dur, value.location.x / w * dur))
                    }
                    .onEnded { value in
                        let pos = max(0, min(dur, value.location.x / w * dur))
                        isDragging = false
                        onSeek(pos)
                    }
            )
        }
        .frame(height: 36)
    }

    @ViewBuilder
    private func markerLine(at x: Double, label: String, color: Color) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 18)
        }
        // -1 centers the 2 pt wide line on the exact position; y: 8 aligns it with the track
        .offset(x: x.clamped(to: 0...1000) - 1, y: 8)
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
