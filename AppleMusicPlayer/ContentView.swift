import SwiftUI
import MediaPlayer

struct ContentView: View {
    @EnvironmentObject var controller: MusicController
    @State private var showPicker = false
    @State private var skipSeconds: Double = 5

    private let skipOptions: [(String, Double)] = [
        ("1s", 1), ("3s", 3), ("5s", 5), ("10s", 10), ("30s", 30)
    ]
    private func gapOptions(abDuration: Double) -> [(String, Double)] {
        [("0s", 0), ("1s", 1), ("2s", 2), (formatTime(abDuration), abDuration)]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    albumArtSection
                    trackInfoSection
                    progressSection
                    skipIntervalPicker
                    playbackControls
                    abRepeatSection
                    chooseSongButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle("Music Transcriber")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showPicker) {
            MediaPickerView(isPresented: $showPicker) { items in
                controller.playItems(items)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Album Art

    private var albumArtSection: some View {
        Group {
            if let art = controller.currentItem?.artwork {
                Image(uiImage: art.image(at: CGSize(width: 240, height: 240)) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Track Info

    private var trackInfoSection: some View {
        VStack(spacing: 4) {
            Text(controller.currentItem?.title ?? "No Song Selected")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(controller.currentItem?.artist ?? "—")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 6) {
            ProgressBarView(
                position: controller.playbackTime,
                duration: controller.duration,
                pointA: controller.pointA,
                pointB: controller.pointB
            ) { time in
                controller.seek(to: time)
            }

            HStack {
                Text(formatTime(controller.playbackTime))
                    .font(.system(.caption, design: .monospaced))

                Spacer()

                if let a = controller.pointA, let b = controller.pointB {
                    let modeLabel = controller.isOneShotEnabled ? "1×" : "Loop"
                    let modeColor: Color = controller.isOneShotEnabled ? .orange : .blue
                    Text("\(modeLabel) \(formatTime(b - a))")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(modeColor)
                    Spacer()
                }

                Text(formatTime(controller.duration))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Skip Interval Picker

    private var skipIntervalPicker: some View {
        VStack(spacing: 6) {
            Text("Skip interval")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(skipOptions, id: \.0) { label, secs in
                    Button(label) { skipSeconds = secs }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(skipSeconds == secs ? .accentColor : .secondary)
                }
            }
        }
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: 14) {
            skipBtn(seconds: -(skipSeconds * 3), icon: "backward.end.fill")
            skipBtn(seconds: -skipSeconds, icon: "backward.fill")

            Button {
                controller.togglePlayPause()
            } label: {
                Image(systemName: controller.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)

            skipBtn(seconds: skipSeconds, icon: "forward.fill")
            skipBtn(seconds: skipSeconds * 3, icon: "forward.end.fill")
        }
    }

    @ViewBuilder
    private func skipBtn(seconds: Double, icon: String) -> some View {
        let abs = Swift.abs(seconds)
        let label = abs == Double(Int(abs)) ? "\(Int(abs))s" : String(format: "%.1fs", abs)
        Button {
            controller.skip(by: seconds)
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.title3)
                Text((seconds < 0 ? "-" : "+") + label)
                    .font(.system(size: 10))
            }
            .frame(width: 52, height: 44)
        }
        .buttonStyle(.bordered)
    }

    // MARK: - A-B Repeat

    private var abRepeatSection: some View {
        VStack(spacing: 10) {
            Text("A-B Repeat")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                // Set A
                Button {
                    controller.setPointA()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "a.circle.fill")
                            .foregroundStyle(controller.pointA != nil ? .green : .secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Set A").font(.caption2)
                            if let a = controller.pointA {
                                Text(formatTime(a))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                // Set B
                Button {
                    controller.setPointB()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "b.circle.fill")
                            .foregroundStyle(controller.pointB != nil ? .red : .secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Set B").font(.caption2)
                            if let b = controller.pointB {
                                Text(formatTime(b))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                // One Shot
                Button {
                    controller.toggleOneShot()
                } label: {
                    Label(
                        controller.isOneShotEnabled ? "1× On" : "1×",
                        systemImage: "arrow.forward.to.line"
                    )
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(controller.isOneShotEnabled ? .orange : nil)
                .disabled(controller.pointA == nil || controller.pointB == nil)

                // Toggle loop
                Button {
                    controller.toggleABRepeat()
                } label: {
                    Label(
                        controller.isABRepeatEnabled ? "Looping" : "Loop",
                        systemImage: "repeat"
                    )
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(controller.isABRepeatEnabled ? .blue : nil)
                .disabled(controller.pointA == nil || controller.pointB == nil)

                // Clear
                Button {
                    controller.clearAB()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .disabled(controller.pointA == nil && controller.pointB == nil)
            }

            if controller.isABRepeatEnabled, let a = controller.pointA, let b = controller.pointB {
                VStack(spacing: 4) {
                    Text("Gap before loop")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 6) {
                        ForEach(gapOptions(abDuration: b - a), id: \.0) { label, secs in
                            Button(label) { controller.loopGapSeconds = secs }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .tint(controller.loopGapSeconds == secs ? .blue : .secondary)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Choose Song

    private var chooseSongButton: some View {
        Button {
            showPicker = true
        } label: {
            Label("Choose Song from Library", systemImage: "music.note.list")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!controller.isAuthorized)
    }

}

#Preview {
    ContentView()
        .environmentObject(MusicController.shared)
}
