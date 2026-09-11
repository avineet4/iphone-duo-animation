# iPhone Duo Animation

A SwiftUI + Metal experiment that turns your iPhone's tilt into a live "iPhone Duo" effect - as if the screen is a hinged bending in response to how you hold the phone.

The app renders a full-screen image and applies a custom Metal shader that warps, dims, and blurs the image along a virtual crease, driven in real time by `CoreMotion` device-attitude data.

## Demo

https://github.com/user-attachments/assets/49790f41-ee9f-4864-a694-c6873f35f27b

## How it works

- **`FoldMotionModel`** reads live device motion via `CMMotionManager`, computes the device's rotation relative to a calibrated reference orientation, and derives a smoothed tilt angle (`liveTilt`) with a small look-ahead term based on rotation rate to reduce perceived latency.
- **`FoldEffectModifier`** is a SwiftUI `ViewModifier` that feeds the current tilt angle and fold parameters into a Metal `layerEffect` shader (`ShaderLibrary.duoFold`), applied via `.visualEffect`.
- **`DuoFold.metal`** is the shader that does the actual per-pixel work — bending the image around a hinge, applying a soft blur near the crease, and dimming based on fold angle to simulate a physical fold/shadow.
- **`FoldParameters`** exposes tunable constants (virtual eye distance, points-per-millimeter, blur spread, dim rate) that control how dramatic and physically plausible the fold looks.
- **`ContentView`** ties it together: it fills the screen with an image and applies `.foldEffect(angle:)`, using the live tilt angle from `FoldMotionModel`.

The result is a screen that visually "hinges" as you tilt the phone, as though it were two panels joined in the middle.

## Requirements

- Xcode 15+
- iOS 17+ (uses `@Observable`, `.visualEffect`, and Metal `layerEffect` shaders, all introduced in iOS 17)
- A physical iPhone with a gyroscope/accelerometer (device motion is not meaningfully simulated in the iOS Simulator)

## Getting started

1. Clone the repository:
   ```bash
   git clone https://github.com/avineet4/iphone-duo-animation.git
   ```
2. Open `iphone-duo-animation.xcodeproj` (or `.xcworkspace`, if present) in Xcode.
3. Select a physical iPhone as the run destination — device motion won't drive the effect on the Simulator.
4. Build and run, then tilt your phone to see the fold effect respond in real time.

## Project structure

```
iphone-duo-animation/
├── iphone_duo_animationApp.swift   # App entry point
├── ContentView.swift               # Root view: renders the image + fold effect
├── FoldEffectModifier.swift        # ViewModifier wrapping the Metal layerEffect
├── FoldMotionModel.swift           # CoreMotion tracking → smoothed tilt angle
├── FoldParameters.swift            # Tunable shader parameters
├── DuoFold.metal                   # Metal shader implementing the fold/blur/dim effect
└── Assets.xcassets/                # App icon, colors, and the source image
```

## Customization

Tweak the look and feel via `FoldParameters`:

| Parameter | Description |
|---|---|
| `eyeDistanceMM` | Virtual viewing distance (mm), affects perceived fold depth |
| `pointsPerMM` | Conversion factor from millimeters to screen points |
| `blurSpread` | Amount of blur applied near the fold crease |
| `dimRate` | How quickly the folded half dims with angle |

You can also swap in your own image by replacing `Duo_iPhone` in `Assets.xcassets`.

## License

Licensed under the [MIT License](LICENSE).
