# Ceylon Snakes - Project Documentation

## 1. Project Overview
**Ceylon Snakes** is a mobile application developed using Flutter, designed to help users in Sri Lanka identify snake species using Artificial Intelligence (AI). The app aims to provide quick identification, safety information, and access to emergency services, including locating nearby hospitals.

## 2. Key Features

### 🐍 Snake Identification (AI)
- **Technology**: Uses a pre-trained **EfficientNetB0** model running on **TensorFlow Lite**.
- **Functionality**: Users can capture a photo or select one from the gallery. The app processes the image and provides:
  - The species name (e.g., Cobra, Russell's Viper).
  - A confidence score.
  - Classification as Venomous or Non-Venomous (Logic intended for `HomeScreen`).

### 🏥 Hospital Locator
- **Technology**: Integration with **Flutter Map (OpenStreetMap)** and **Overpass API**.
- **Functionality**:
  - Detects the user's current GPS location.
  - Fetches real-time data of nearby hospitals within a **5km radius**.
  - Displays hospitals as markers on an interactive map.
  - Provides a list view of hospitals with addresses.
  - Allows users to launch **Google Maps** for turn-by-turn directions.

### 🚑 Emergency Services
- **Quick Action**: A floating action button (FAB) to instantly dial **1990** (Suwa Seriya Ambulance Service).
- **Emergency Screen**: Dedicated screen for emergency protocols (details in `emergency_screen.dart`).

### 🌗 Dark & Light Mode
- **System**: dynamic theming using `Provider`.
- **Functionality**: Users can switch between Light, Dark, or System Default themes. The UI adapts colors (backgrounds, text, cards) accordingly.

### 📚 Snake Library
- *Status*: Currently a placeholder ("Coming Soon").
- *Goal*: To provide a detailed encyclopedia of Sri Lankan snakes.

## 3. Technical Architecture

### Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: `Provider`
- **Map Provider**: `flutter_map` (OpenStreetMap) & `latlong2`
- **AI/ML**: `flutter_tflite` (TensorFlow Lite)
- **Location**: `geolocator`
- **Networking**: `http` (for Overpass API)
- **Local Storage**: `shared_preferences` (for persisting theme settings)

### Project Structure (`lib/`)
```
lib/
├── main.dart                  # Application entry point, Theme setup, Routes
├── providers/
│   └── theme_provider.dart    # Manages application theme state (Dark/Light)
├── screens/
│   ├── main_screen.dart       # Main container with BottomNavigationBar
│   ├── home_screen.dart       # Dashboard & Image Picker logic
│   ├── hospital_screen.dart   # Map implementation & Hospital logic
│   ├── result_screen.dart     # Displays classification results
│   ├── emergency_screen.dart  # Emergency contact & info
│   └── splash_screen.dart     # Initial loading screen
└── services/
    └── classifier.dart        # Singleton service handling TFLite model loading & inference
```

## 4. Setup & Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android Device or Emulator

### Installation Steps
1.  **Clone the repository**:
    ```bash
    git clone <repository_url>
    cd ceylon_snakes
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Asset Setup**:
    Ensure the TFLite model and assets are correctly placed:
    - `assets/models/model.tflite`
    - `assets/models/labels.txt`
    - `assets/images/logo.png`
4.  **Run the App**:
    ```bash
    flutter run
    ```

## 5. Permissions
The app requires the following permissions (configured in `AndroidManifest.xml` and `Info.plist`):
- **Camera**: To take photos of snakes.
- **Location**: To find the user's position for the hospital locator.
- **Internet**: To fetch map tiles and hospital data.

## 6. Future Roadmap
- Complete the **Snake Library** with detailed species information.
- Enhance the AI model for higher accuracy and more species.
- Add offline support for hospital data.
