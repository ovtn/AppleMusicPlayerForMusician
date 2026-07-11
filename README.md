# AppleMusicPlayer for Musicians

An iOS app built for musicians who transcribe music. It plays tracks from your Apple Music library with precise A-B loop controls, one-shot playback, and a loop gap feature — everything you need to repeatedly listen to a passage while writing it down.

## Features

### A-B Loop
Set two points (A and B) on the progress bar to define a region. Setting A always clears B so you start fresh from a new anchor point. Setting B automatically enables looping — no extra button press needed. The A-B region is highlighted on the scrubber so you always know where you are.

### One Shot (1×)
Play from A to B exactly once, then stop. Press play again to repeat from A. When One Shot is active, setting B does not auto-enable loop. Useful when you want to hear a passage at your own pace rather than on a continuous loop.

### Loop Toggle
After loop is auto-enabled by setting B, you can toggle it off to leave the A-B markers in place without looping — handy when you want to scrub freely within the region.

### Loop with Gap
When looping, insert a configurable pause between reaching B and returning to A. Choose from 0s, 1s, 2s, or the exact duration of the A-B region itself. The gap gives you time to write down what you just heard before the next repeat starts.

### Precise Scrubbing
- Draggable progress bar with A/B markers
- Playback time displayed in `M:SS.t` format (tenth-of-second precision)
- Skip buttons with selectable intervals: 1s, 3s, 5s, 10s, 30s

### Apple Music Catalog Search *(requires Apple Developer Program)*
The app includes a catalog search interface built on MusicKit. The feature is disabled by default — to enable it, join the Apple Developer Program, enable MusicKit for the App ID in the developer portal, and change `disabled(true)` to `disabled(!controller.isMusicKitAuthorized)` in `ContentView.swift`.

## Requirements

- iOS 17.0+
- Apple Music library access

## Build

Open `AppleMusicPlayer.xcodeproj` in Xcode, select your target device, and run. The app requires a physical device for Apple Music playback — the simulator does not support `MPMusicPlayerController`.
