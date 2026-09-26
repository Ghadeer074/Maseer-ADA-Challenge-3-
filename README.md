# Maseer – Accessible Navigation Assistant for iOS

> *"You know your destination… and the path knows its features."*

**Maseer** is an accessibility-first iOS app that helps **blind and low-vision users** understand their surroundings. The user points the iPhone camera ahead, and Maseer reads signs in real time. It then tells the user **what the sign says, where it is (left, front or right) and roughly how far away it is**, spoken through **VoiceOver**. Past descriptions are saved so the user can review them later.

The app was built by a team at the **Apple Developer Academy** (Challenge 3).

<!-- Add 2–3 screenshots here, e.g.:
<p align="center">
  <img src="docs/home.png" width="230"> <img src="docs/camera.png" width="230"> <img src="docs/history.png" width="230">
</p>
-->

## Features

- **Live sign reading:** uses the Vision framework (`VNRecognizeTextRequest`) on camera frames to find the most prominent text in view
- **Spatial guidance:** estimates the sign's direction (left, front or right) and its approximate distance from the text's position and size in the frame
- **Built for VoiceOver:** custom accessibility labels, hints and announcements on every screen
- **Location-aware:** gets the user's location with Core Location before starting a scan
- **History:** saves each description with SwiftData so the user can review or delete it later
- **Arabic-first:** Arabic and English localization with full right-to-left (RTL) layout

## Tech Stack

| Area | Technology |
|---|---|
| Language & UI | Swift, SwiftUI (NavigationStack, Liquid Glass effects) |
| Architecture | MVVM |
| Computer Vision | Vision (text recognition), AVFoundation (live camera capture) |
| Location | Core Location |
| Persistence | SwiftData |
| Accessibility & Localization | VoiceOver, String Catalog (`Localizable.xcstrings`), RTL |

## Project Structure

```
MaseerApp/
├── Model/
│   └── HistoryItem.swift        # SwiftData model for saved descriptions
├── ViewModel/
│   ├── AICameraVM.swift         # Camera session + Vision text recognition + guidance logic
│   └── LocationManager.swift    # Observable wrapper around CLLocationManager
└── View/
    ├── RootView.swift           # NavigationStack routing between all screens
    ├── HomepageView.swift
    ├── locatingCompass.swift    # "Locating you" screen
    ├── AICameraView.swift       # Live camera + spoken descriptions
    ├── HistoryPage.swift / HistoryRow.swift / HistoryInfoView.swift
    └── Accessibility.swift      # VoiceOver announcement helper
```

## Getting Started

**Requirements:** Xcode 26+, iOS 26+, and a **physical iPhone** (the camera doesn't work in the Simulator).

```bash
git clone https://github.com/Ghadeer074/Maseer-ADA-Challenge-3-.git
open Maseer-ADA-Challenge-3-/MaseerApp.xcodeproj
```

Select your device, then build and run. Allow **camera** and **location** access when prompted.

## My Contributions

I built the app's **backend**, working together with Feda and Asma:

- **Vision:** real-time text recognition on camera frames, plus the direction and distance guidance logic
- **AVFoundation:** the live camera capture pipeline
- **Core Location:** location tracking and the camera and location privacy permissions
- **Data:** the SwiftData history model, including saving, listing and deleting records
- **VoiceOver:** accessibility labels, hints and announcements, plus Arabic RTL support
- **Architecture:** the MVVM project structure, with all screens connected in `RootView` through a typed `NavigationStack`

## Team

- **Backend:** Ghadeer Fallatah ([@Ghadeer074](https://github.com/Ghadeer074)) · Feda · Asma
- **Team members:** Bushra Alhejaili ([@Bushrahalhejaili](https://github.com/Bushrahalhejaili)) · Reeman
