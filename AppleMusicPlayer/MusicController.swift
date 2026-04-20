import Foundation
import MediaPlayer
import AVFoundation

@MainActor
final class MusicController: ObservableObject {
    static let shared = MusicController()

    @Published var isPlaying = false
    @Published var currentItem: MPMediaItem? = nil
    @Published var playbackTime: Double = 0
    @Published var duration: Double = 0
    @Published var pointA: Double? = nil
    @Published var pointB: Double? = nil
    @Published var isABRepeatEnabled = false
    @Published var isOneShotEnabled = false
    @Published var loopGapSeconds: Double = 0
    @Published var isAuthorized = false

    let player = MPMusicPlayerController.applicationMusicPlayer
    private var pollingTimer: Timer?
    private var gapTimer: Timer?
    private var isSeeking = false
    private var isInGap = false

    private init() {
        configureAudioSession()
        setupNotifications()
        startPolling()
        requestAuthorization()
    }

    deinit {
        pollingTimer?.invalidate()
        player.endGeneratingPlaybackNotifications()
    }

    // MARK: - Setup

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback, mode: .default,
            options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func requestAuthorization() {
        let status = MPMediaLibrary.authorizationStatus()
        if status == .authorized {
            isAuthorized = true
        } else if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async { self?.isAuthorized = newStatus == .authorized }
            }
        }
    }

    private func setupNotifications() {
        player.beginGeneratingPlaybackNotifications()

        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: player, queue: .main
        ) { [weak self] _ in self?.syncPlaybackState() }

        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player, queue: .main
        ) { [weak self] _ in self?.syncNowPlayingItem() }
    }

    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // .common keeps the timer firing during scroll/drag interactions (default .default mode pauses it)
        RunLoop.main.add(pollingTimer!, forMode: .common)
    }

    // MARK: - Polling

    private func tick() {
        guard !isSeeking else { return }
        let t = player.currentPlaybackTime
        guard t.isFinite, t >= 0 else { return }
        playbackTime = t

        guard let b = pointB, isPlaying, playbackTime >= b else { return }

        if isOneShotEnabled {
            player.pause()
        } else if isABRepeatEnabled, !isInGap {
            if loopGapSeconds > 0 {
                // isInGap prevents the 100 ms tick from re-triggering this block during the wait
                isInGap = true
                player.pause()
                gapTimer = Timer.scheduledTimer(withTimeInterval: loopGapSeconds, repeats: false) { [weak self] _ in
                    // Timer callbacks are not actor-isolated; Task hops back to @MainActor
                    Task { @MainActor [weak self] in
                        // isInGap may have been cleared by cancelGap() between the timer firing and this Task running
                        guard let self, self.isInGap else { return }
                        self.isInGap = false
                        self.seekInternal(to: self.pointA ?? 0)
                        self.player.play()
                    }
                }
                RunLoop.main.add(gapTimer!, forMode: .common)
            } else {
                seekInternal(to: pointA ?? 0)
            }
        }
    }

    private func syncPlaybackState() {
        isPlaying = player.playbackState == .playing
    }

    private func syncNowPlayingItem() {
        currentItem = player.nowPlayingItem
        duration = currentItem?.playbackDuration ?? 0
        clearAB()
    }

    // MARK: - Playback controls

    func playItems(_ items: [MPMediaItem]) {
        guard !items.isEmpty else { return }
        let collection = MPMediaItemCollection(items: items)
        player.setQueue(with: collection)
        player.play()
    }

    func togglePlayPause() {
        if player.playbackState == .playing {
            player.pause()
        } else {
            // Seek to A before resuming so that play always starts a fresh A→B run,
            // not from wherever playback stopped (which is at B after the previous shot).
            if isOneShotEnabled, let a = pointA {
                seekInternal(to: a)
            }
            player.play()
        }
    }

    func seek(to time: Double) {
        cancelGap()
        seekInternal(to: time)
    }

    func skip(by seconds: Double) {
        cancelGap()
        seekInternal(to: playbackTime + seconds)
    }

    private func seekInternal(to time: Double) {
        let clamped = max(0, duration > 0 ? min(duration, time) : time)
        // isSeeking suppresses tick() for 150 ms because MPMusicPlayerController.currentPlaybackTime
        // briefly reports the pre-seek position after the property is set, which would cause a visible
        // snap-back in the progress bar.
        isSeeking = true
        player.currentPlaybackTime = clamped
        playbackTime = clamped
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.isSeeking = false
        }
    }

    // MARK: - A-B Repeat

    func setPointA() {
        pointA = playbackTime
        if let b = pointB, b <= playbackTime {
            pointB = nil
            isABRepeatEnabled = false
        }
    }

    func setPointB() {
        pointB = playbackTime
        if let a = pointA, a >= playbackTime {
            pointA = nil
            isABRepeatEnabled = false
        }
    }

    func toggleABRepeat() {
        guard pointA != nil, pointB != nil else { return }
        isABRepeatEnabled.toggle()
        if isABRepeatEnabled {
            isOneShotEnabled = false
            cancelGap()
            if let a = pointA { seekInternal(to: a) }
        } else {
            cancelGap()
        }
    }

    func toggleOneShot() {
        guard pointA != nil, pointB != nil else { return }
        isOneShotEnabled.toggle()
        if isOneShotEnabled {
            isABRepeatEnabled = false
            cancelGap()
            if let a = pointA { seekInternal(to: a) }
        }
    }

    private func cancelGap() {
        gapTimer?.invalidate()
        gapTimer = nil
        isInGap = false
    }

    func clearAB() {
        pointA = nil
        pointB = nil
        isABRepeatEnabled = false
        isOneShotEnabled = false
        cancelGap()
    }
}
