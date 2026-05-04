# Sarang (사랑)

**Sarang** is a high-performance iOS relationship management application built with SwiftUI and Firebase. It addresses the common challenge of "decision fatigue" in modern relationships by utilizing a proprietary compatibility engine and a swipe-based discovery interface to facilitate real-world date scheduling.

---

## 📱 Project Overview

Unlike traditional date-list apps, Sarang focuses on the **Exploration Trait** methodology. Users complete an integrated assessment to determine their dating archetype, which then informs a real-time compatibility algorithm when paired with a partner.

### Core Features
* **The Discovery Deck:** A custom-engineered card stack utilizing advanced gestures and haptic feedback.
* **Vibe Compatibility Engine:** A multi-dimensional logic system that compares Energy, Setting, Social, and Discovery preferences.
* **Secure Handshake:** A request-and-accept partner linking system built on Firestore transaction batches.
* **Identity Management:** Dynamic avatar generation via the DiceBear API and native photo library integration.
* **Production Resilience:** Full compliance with App Store guidelines, including account deletion flows and granular security rules.

---

## 🛠 Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend** | SwiftUI, PhotosUI, CoreHaptics |
| **Backend** | Firebase (Firestore, Authentication, Storage) |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Tools** | Xcode 15+, Git, CocoaPods/SPM |

---

## 🏗 Architecture & Data Design

The application follows the **MVVM pattern** to ensure a strict separation of concerns, facilitating easier testing and scalability. 

### Data Models
* `AppUser`: Manages user identity, archetypes, and connection status.
* `ExplorationTrait`: A type-safe enum system defining the eight core dating archetypes.
* `DateIdea`: A Firestore-backed schema for experience recommendations.
* `PartnerRequest`: Handles the temporary state during the partner linking handshake.

---

## 🚀 Getting Started

### Prerequisites
* Mac running macOS Sonoma or later.
* Xcode 15.0+ installed.
* A Firebase project configured for iOS.

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/sarang.git](https://github.com/yourusername/sarang.git)
   
2. Open the project in Xcode:
   ```bash
   cd sarang
   open sarang.xcodeproj
Add your GoogleService-Info.plist to the root directory.

Ensure the bundle identifier matches your Firebase project configuration.

Build and run (Cmd + R) on an iPhone simulator or physical device.

🔒 Security Rules
The project implements strict Firestore security rules to protect user privacy:

Users: Read access is permitted for authenticated users; write access is restricted to the account owner, with the exception of the partnerId field during the link handshake.

Swipes: Private sub-collections ensure users can only view their own swipes or those of their officially linked partner.

Matches: Only accessible if the user's UID is present in the specific match's pair array.

🗺 Roadmap
[x] Phase 1: Foundation - Authentication, Firestore setup, and basic swiping logic.

[x] Phase 2: Compatibility - Exploration Trait quiz and real-time match engine.

[x] Phase 3: Connections - Partner request flow and profile personalization.

[ ] Phase 4: Optimization - Local data caching and offline persistence.

[ ] Phase 5: Release - App Store submission and TestFlight beta testing.

⚖️ License
Distributed under the MIT License. See LICENSE for more information.

Samuel Lee GitHub | LinkedIn
