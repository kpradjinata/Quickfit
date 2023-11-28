# Fitness AR App

Track body motion in 3D, visualize movements, and receive feedback for fitness exercises.

## Overview

This iOS app utilizes ARKit to capture body motion in the physical environment and applies the movements to a virtual character. The goal is to assist users in performing fitness exercises with real-time feedback.

## Features

- Body motion tracking in 3D space
- Virtual character visualization
- Real-time feedback for fitness exercises

## Getting Started

To run the app, use an iOS device with an A12 chip or later.

### Prerequisites

- Xcode
- iOS device with A12 chip or later

### Installation

1. Clone the repository.
2. Open the project in Xcode.
3. Build and run the app on your iOS device.

## Usage

1. Open the app on your iOS device.
2. Follow on-screen instructions for body motion tracking.
3. Receive real-time feedback for fitness exercises.

## Project Structure

The project structure is organized into two main parts:
- **Main App:** Captures and processes body motion.
- **ARViewController:** Manages ARKit session and handles body tracking.

## Dependencies

- ARKit
- RealityKit
- Combine
- AVFoundation

Install the required dependencies using the following command:

```bash
pod install
```

## License
This project is licensed under the MIT License.

## Acknowledgments
The app was developed based on the WWDC 2019 session Bringing People into AR.
Special thanks to contributors and libraries used in the development process.
