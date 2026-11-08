# Clinic Queue (`clinic-queue`) 🏥

[![CI Workflow](https://github.com/crnjihia/clinic-queue/actions/workflows/ci.yml/badge.svg)](https://github.com/crnjihia/clinic-queue/actions/workflows/ci.yml)
[![Release v1.0.0](https://img.shields.io/badge/Release-v1.0.0-blue.svg)](https://github.com/crnjihia/clinic-queue/releases/tag/v1.0.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20FCM-FFCA28?logo=firebase)](https://firebase.google.com)

**Clinic Queue** is a production-grade, portfolio-quality outpatient clinic appointment scheduling and live queue management system built for Kenyan healthcare facilities. Patients book available slots, track their queue position in real time with estimated wait times, receive automated Swahili/English FCM push alerts and Africa's Talking SMS notifications when they are next, and clinic staff seamlessly manage and advance patient consultation queues.

---

## 📱 Application Screenshots

<div align="center">
  <img src="docs/assets/screenshots/clinics_list.png" width="30%" alt="Nairobi Clinics List" />
  <img src="docs/assets/screenshots/live_queue.png" width="30%" alt="Live Queue Ticket" />
  <img src="docs/assets/screenshots/app_settings.png" width="30%" alt="Compact App Settings" />
</div>

| Nairobi Clinics Discovery | Live Queue Ticket (`#A042`) | Zero-Scroll Settings (Dark Mode) |
| :---: | :---: | :---: |
| Sub-county filtering (`Kibra`, `Westlands`, `Embakasi`) and real-time slot availability. | Real-time position tracking, M-PESA PAID receipt pill, and estimated wait duration. | Bilingual English/Swahili toggle, Dark Theme switch, FCM/SMS toggles, and Role switcher. |

---

## 📐 System Architecture

### Clean Layering Overview
```mermaid
graph TD
    subgraph "Presentation Layer"
        UI[Flutter UI Widgets & Screens]
        BLoC[AuthBloc / BookingBloc / QueueBloc / StaffBloc]
    end

    subgraph "Domain Layer (Pure Dart)"
        Entities[Clinic / QueueSlot / Ticket / Payment / UserProfile]
        UseCases[BookSlot / InitiatePayment / AdvanceQueue / WatchLiveQueue]
        RepoInterfaces[AuthRepository / QueueRepository / ClinicRepository / PaymentRepository]
    end

    subgraph "Data Layer"
        RepoImpl[AuthRepositoryImpl / QueueRepositoryImpl / PaymentRepositoryImpl]
        DataSources[FirestoreQueueDataSource / MpesaRemoteDataSource / FcmRemoteDataSource]
        FirebaseSDK[Firebase Firestore, Auth & Cloud Functions SDKs]
    end

    UI --> BLoC
    BLoC --> UseCases
    UseCases --> RepoInterfaces
    RepoImpl ..|> RepoInterfaces
    RepoImpl --> DataSources
    DataSources --> FirebaseSDK
```

### Live Queue State Machine & FCM/SMS Triggers
```mermaid
stateDiagram-v2
    [*] --> Waiting : Patient books slot / pays M-Pesa
    Waiting --> Called : Staff calls ticket (Triggers FCM Push & AT SMS)
    Called --> InService : Patient enters consultation bay
    Waiting --> Cancelled : Patient cancels ticket
    Called --> NoShow : Patient does not respond
    InService --> Done : Consultation complete
    Done --> [*]
    Cancelled --> [*]
    NoShow --> [*]
```

---

## 🚀 Key Features & Kenya Context

- **Safaricom M-Pesa Daraja Integration**: Integrated Lipa na M-PESA STK Push payment modal for outpatient consultation fees (`KES 500`), with asynchronous webhook callbacks in Cloud Functions updating Firestore payment status.
- **Africa's Talking SMS Fallback**: Automated SMS notifications dispatched via Africa's Talking API when patients are backgrounded or offline.
- **Kenyan Telephony & Timezone**: Strict `+254` Safaricom/Airtel phone number validation (`+2547XXXXXXXX` or `+2541XXXXXXXX`), localized currency display (**KES**), and `Africa/Nairobi` timezone scheduling.
- **Bilingual Localisation**: Dynamic UI copy and push notification templates supporting **Swahili (`sw`)** and **English (`en`)** (*"You are next! (Foleni wa Kliniki)"*).
- **Working Dark Theme & Compact Settings**: Zero-scroll compact settings page with working Dark Theme toggle (`ValueNotifier<ThemeMode>`) and instant Role Portal Switcher (**Patient** vs **Clinical Staff**).
- **Offline Resilience**: Firestore offline persistence enabled with visual `NetworkBanner` state indicating "Offline, showing last known queue".
- **Zero Diagnostic Data Logging**: Only non-diagnostic appointment reason codes (e.g., `TRIAGE_GENERAL`, `CHILD_WELFARE`) stored to strictly preserve patient privacy.

---

## 🛠️ Tech Stack

- **Mobile Framework**: Flutter 3.19+ / Dart 3
- **State Management**: BLoC (`flutter_bloc`, `bloc_test`)
- **Dependency Injection**: `get_it` + `injectable`
- **Routing**: `go_router` with reactive auth & role guards
- **Backend & Cloud Services**: Firebase Auth, Cloud Firestore, Cloud Messaging (FCM)
- **Cloud Infrastructure**: Firebase Cloud Functions (TypeScript)
- **Local Testing Environment**: Firebase Emulator Suite (`auth`, `firestore`, `functions`)
- **Testing**: `flutter_test`, `bloc_test`, `mockito`, `alchemist` (Golden UI tests), `integration_test`
- **Build & CI/CD**: Fastlane + GitHub Actions CI workflow

---

## 💻 Quick Start & Local Development

### Prerequisites
- [Flutter SDK 3.19+](https://docs.flutter.dev/get-started/install)
- [Node.js 18+](https://nodejs.org/)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- Java Development Kit (JDK 17+) for Firebase Emulators

### 1. Repository Setup
```bash
# Clone the repository
git clone https://github.com/crnjihia/clinic-queue.git
cd clinic-queue

# Install dependencies
cd functions && npm install
cd ../apps/mobile && flutter pub get
```

### 2. Start Firebase Emulator Suite
Launch local auth, firestore, and cloud functions emulators:
```bash
npx -y firebase-tools@latest emulators:start --only auth,firestore,functions
```
*The Firebase Emulator UI will be accessible at [http://127.0.0.1:4000](http://127.0.0.1:4000).*

### 3. Seed Synthetic Test Data
In a separate terminal window, populate local Firestore with Nairobi clinic records:
```bash
cd functions
npx ts-node src/seedEmulator.ts
```

### 4. Run the Mobile App (Dev Flavor)
```bash
cd apps/mobile
flutter run -t lib/main_dev.dart --flavor dev
```

---

## 🧪 Testing Suite

Execute unit, BLoC, and widget tests:

```bash
# Run mobile unit and widget tests
cd apps/mobile
flutter test test/unit/ test/widget_test.dart

# Run static analysis
flutter analyze
```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
