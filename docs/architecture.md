# Architectural Specification: Clinic Queue (`clinic-queue`)

## 1. Architectural Overview

`clinic-queue` follows **Clean Architecture** principles strictly separated into three layers to promote testability, maintainability, and domain independence.

```
+-------------------------------------------------------------------+
|                        Presentation Layer                         |
|   Flutter Screens | Custom Widgets | BLoC (Auth, Booking, Queue)  |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                          Domain Layer                             |
|  Entities (Pure Dart) | Repository Contracts | Use Cases          |
+-------------------------------------------------------------------+
                                  ^
                                  |
+-------------------------------------------------------------------+
|                           Data Layer                              |
|   Repository Implementations | Data Sources (Firestore, FCM)      |
+-------------------------------------------------------------------+
```

---

## 2. Layering Principles & Rules

1. **Domain Layer Independence**:
   - Contains zero dependencies on Flutter framework UI components or 3rd party SDKs (including Firebase).
   - Entities (`Clinic`, `QueueSlot`, `Ticket`, `UserProfile`) are plain immutable Dart objects using `Equatable`.
   - Use Cases encapsulate single business operations (`BookSlotUseCase`, `AdvanceQueueUseCase`).

2. **Data Layer Isolation**:
   - All Firebase Firestore, Auth, and FCM interactions are restricted exclusively to `data/datasources/`.
   - Data models (`TicketModel`, `ClinicModel`) handle `toFirestore()` and `fromFirestore()` conversions.
   - Repositories convert exceptions into unified `Failure` domain objects.

3. **Presentation Layer**:
   - State management powered by `flutter_bloc`.
   - UI widgets consume state and dispatch events.
   - Routing managed by `go_router` with reactive auth state redirects.

---

## 3. Firestore Data Model & Schema

```
/clinics/{clinicId} (Document)
  ├── id: String
  ├── name: String
  ├── location: String
  ├── isActive: Boolean
  ├── averageConsultationMinutes: Int
  │
  ├── /slots/{slotId} (Collection)
  │     ├── id: String
  │     ├── startTime: Timestamp
  │     ├── endTime: Timestamp
  │     ├── capacity: Int
  │     └── bookedCount: Int
  │
  └── /queue/{ticketId} (Collection)
        ├── id: String
        ├── clinicId: String
        ├── patientId: String
        ├── ticketNumber: String (e.g., "A001")
        ├── status: String ("waiting" | "called" | "in_service" | "done" | "no_show" | "cancelled")
        ├── joinedAt: Timestamp
        ├── serviceStartedAt: Timestamp (optional)
        ├── serviceCompletedAt: Timestamp (optional)
        └── reasonCode: String (e.g., "TRIAGE_GENERAL")

/users/{uid} (Document)
  ├── uid: String
  ├── email: String
  ├── displayName: String
  ├── phoneNumber: String
  ├── role: String ("patient" | "staff")
  └── fcmTokens: Array<String>
```

---

## 4. Security & Data Privacy Guidelines

- **No Medical/Diagnostic Data**: Storage of diagnostic records or clinical notes in Firestore is prohibited. Only non-diagnostic appointment codes (`TRIAGE_GENERAL`, `ROUTINE_CHECKUP`, `PHARMACY_PICKUP`) are permitted.
- **Role-Based Security Rules**:
  - Patients can create and update their own tickets (`waiting` -> `cancelled`).
  - Staff members have read/write access across clinic queues to call patients and update statuses.
  - Deletion of queue documents is restricted to preserve clinic audit trails.

---

## 5. Cloud Functions & Push Notification Topology

```
   Firestore Document Mutation
 (clinics/{id}/queue/{ticketId})
               │
               ▼
┌──────────────────────────────┐
│  onQueueTicketWritten        │
│  Cloud Function Trigger      │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│  evaluateAndSendQueueAlert   │
│  - Query active queue        │
│  - Calculate position ahead  │
└──────────────┬───────────────┘
               │
        Position <= 2?
        ├── YES ──> Fetch User FCM Tokens ──> FCM Multicast Push
        └── NO  ──> Log evaluation result
```
