# 🐍 Ceylon Snakes

**Ceylon Snakes** is a Flutter mobile app that helps people in Sri Lanka identify snake species using AI, find nearby hospitals, and reach emergency services quickly.

---

## ✨ Features

### 🐍 AI Snake Identification
- Powered by a pre-trained **EfficientNetB0** model running on **TensorFlow Lite**
- Capture a photo or pick one from the gallery
- Get the **species name**, a **confidence score**, and whether the snake is **venomous or non-venomous**

### 🏥 Hospital Locator
- Detects your GPS location
- Fetches hospitals within a **5 km radius** using the **Overpass API**
- Shows results on an interactive **OpenStreetMap** map and in a list view
- Opens **Google Maps** for turn-by-turn directions

### 🚑 Emergency Services
- Floating action button to instantly dial **1990** (Suwa Seriya Ambulance Service)
- Dedicated emergency screen with protocols and contact info

### 🌗 Dark & Light Mode
- Light, Dark, or System Default themes
- Preference is saved using `shared_preferences`

### 📚 Snake Library
- *Coming soon:* a detailed encyclopedia of Sri Lankan snakes

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Maps | flutter_map (OpenStreetMap), latlong2 |
| AI / ML | flutter_tflite (TensorFlow Lite) |
| Location | geolocator |
| Networking | http (Overpass API) |
| Local Storage | shared_preferences |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point, theme setup, routes
├── providers/
│   └── theme_provider.dart    # Dark/Light theme state
├── screens/
│   ├── main_screen.dart       # Container with BottomNavigationBar
│   ├── home_screen.dart       # Dashboard & image picker logic
│   ├── hospital_screen.dart   # Map & hospital logic
│   ├── result_screen.dart     # Classification results
│   ├── emergency_screen.dart  # Emergency contacts & info
│   └── splash_screen.dart     # Initial loading screen
└── services/
    └── classifier.dart        # TFLite model loading & inference (singleton)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android Studio or VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/VishwaSaranga/Ceylon_Snakes.git
   cd Ceylon_Snakes
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Check the assets**
   Make sure these files exist:
   - `assets/models/model.tflite`
   - `assets/models/labels.txt`
   - `assets/images/logo.png`

4. **Run the app**
```bash
   flutter run
```

---

## 🔐 Permissions

| Permission | Purpose |
|------------|---------|
| Camera | Take photos of snakes |
| Location | Find nearby hospitals |
| Internet | Load map tiles and hospital data |

---

## 🗺️ Roadmap

- [ ] Complete the Snake Library with detailed species information
- [ ] Improve AI model accuracy and add more species
- [ ] Offline support for hospital data

---

## ⚠️ Disclaimer

This app is an aid and **not a substitute for professional medical advice**. If someone is bitten by a snake, seek medical help immediately by calling **1990**.

---

## 👤 Author

**Vishwa Saranga**
GitHub: [@VishwaSaranga](https://github.com/VishwaSaranga)
