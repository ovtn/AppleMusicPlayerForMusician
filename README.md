# AppleMusicPlayer for Musicians

An iOS app built for musicians who transcribe music. It plays tracks from your Apple Music library with precise A-B loop controls, one-shot playback, and a loop gap feature — everything you need to repeatedly listen to a passage while writing it down.

## Features

### A-B Loop
Set two points (A and B) on the progress bar and loop the region between them. The A-B region is highlighted on the scrubber so you always know where you are.

### One Shot (1×)
Play from A to B exactly once, then stop. Press play again to repeat from A. Useful when you want to hear a passage at your own pace rather than on a continuous loop.

### Loop with Gap
When looping, insert a configurable pause between reaching B and returning to A. Choose from 0s, 1s, 2s, or the exact duration of the A-B region itself. The gap gives you time to write down what you just heard before the next repeat starts.

### Precise Scrubbing
- Draggable progress bar with A/B markers
- Playback time displayed in `M:SS.t` format (tenth-of-second precision)
- Skip buttons with selectable intervals: 1s, 3s, 5s, 10s, 30s

## Requirements

- iOS 16.0+
- Apple Music library access

## Build

Open `AppleMusicPlayer.xcodeproj` in Xcode, select your target device, and run. The app requires a physical device for Apple Music playback — the simulator does not support `MPMusicPlayerController`.
