# Firebase Emulator Setup & Verification Guide 🏥

This guide outlines how to execute the entire **Clinic Queue (`clinic-queue`)** stack locally using the **Firebase Emulator Suite** with 100% test isolation.

---

## 1. Environment Prerequisites

Ensure the following tools are installed on your machine:
- **Node.js**: v18.0.0+
- **Firebase CLI**: `npm install -g firebase-tools`
- **Flutter SDK**: v3.19.0+
- **Java JDK**: 17+ (Required by Firebase Java-based emulators)

---

## 2. Step-by-Step Emulator Startup

### Step A: Install Project Dependencies
Run the top-level setup command:
```bash
make setup
```

### Step B: Start Firebase Emulator Suite
In a dedicated terminal, start Auth, Firestore, and Cloud Functions emulators:
```bash
make emulator
```
*Port Mapping:*
- **Auth Emulator**: `127.0.0.1:9099`
- **Firestore Emulator**: `127.0.0.1:8080`
- **Cloud Functions**: `127.0.0.1:5001`
- **Emulator Suite UI**: `http://127.0.0.1:4000`

---

## 3. Seed Synthetic Test Data

Populate the local Firestore emulator with realistic Nairobi health facility records:

```bash
cd functions
npm run seed
```

This seeds:
1. **Clinics**:
   - Mbagathi Hospital (Kibra Sub-County)
   - Mama Lucy Kibaki Hospital (Embakasi Central)
   - Pumwani Maternity Hospital (Kamukunji)
2. **Slots**: 10 time slots per clinic for today's schedule.
3. **Queue Tickets**: Sample active tickets (`A001` - `A005`).

---

## 4. Run Mobile App in Dev Flavor

Launch the Flutter app targeting the local emulators:

```bash
make dev
```

---

## 5. End-to-End Live Queue & Notification Verification Flow

1. **Patient Sign-In**:
   - Open app -> enter Kenyan phone number `0712 345 678`.
   - Select role: **Patient**.
2. **Book Appointment**:
   - Tap **Mbagathi Hospital** -> Select `09:00 AM - 09:30 AM` slot.
   - Click **Proceed to M-Pesa Payment & Join Queue**.
   - Confirm simulated M-Pesa STK Push -> Ticket **#A042** issued.
3. **Advance Queue via Staff Portal**:
   - Open side tab -> Select role: **Clinical Staff**.
   - In Staff Triage Console, tap **Call Next Patient**.
4. **Demonstrate Cloud Function Push Alert ("You are next!")**:
   - When queue tickets ahead decrease to 1 or 0, check terminal logs in `make emulator`:
     ```text
     i  functions: Queue alert evaluation for ticket ticket_A042: fcmSent=true, smsSent=true, position=1, tokens=1
     ```
   - Verify push notification banner *"You are next! (Foleni wa Kliniki)"* on the patient's device.
