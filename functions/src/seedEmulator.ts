// path: functions/src/seedEmulator.ts
import * as admin from "firebase-admin";

// Automatically default to local emulator if environment variables are not set
if (!process.env.FIRESTORE_EMULATOR_HOST) {
  process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
}
if (!process.env.GCLOUD_PROJECT) {
  process.env.GCLOUD_PROJECT = "clinic-queue-dev";
}

if (admin.apps.length === 0) {
  admin.initializeApp({
    projectId: process.env.GCLOUD_PROJECT,
  });
}

const db = admin.firestore();

export async function seedEmulator(): Promise<void> {
  console.log("=================================================");
  console.log("🌱 Seeding Firebase Emulator with Kenyan Clinic Data");
  console.log(`📡 Target Host: ${process.env.FIRESTORE_EMULATOR_HOST}`);
  console.log(`🏢 Project ID:  ${process.env.GCLOUD_PROJECT}`);
  console.log("=================================================");

  // 1. Seed User Profiles (Staff & Patients)
  console.log("👤 Seeding user accounts and roles...");
  const users = [
    {
      uid: "staff_wangari",
      displayName: "Nurse Wangari",
      phoneNumber: "+254711223344",
      role: "staff",
      fcmTokens: ["test_token_staff_wangari"],
    },
    {
      uid: "staff_ochieng",
      displayName: "Dr. Ochieng",
      phoneNumber: "+254722334455",
      role: "staff",
      fcmTokens: ["test_token_staff_ochieng"],
    },
    {
      uid: "patient_chris",
      displayName: "Chris Ndung'u",
      phoneNumber: "+254712345678",
      role: "patient",
      fcmTokens: ["test_token_patient_chris"],
    },
    {
      uid: "patient_amina",
      displayName: "Amina Mohamed",
      phoneNumber: "+254722001122",
      role: "patient",
      fcmTokens: ["test_token_patient_amina"],
    },
  ];

  for (const user of users) {
    await db.collection("users").doc(user.uid).set({
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      role: user.role,
      fcmTokens: user.fcmTokens,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`   ✓ User [${user.role.toUpperCase()}] ${user.displayName} (${user.uid})`);
  }

  // 2. Seed Public Clinics Directory
  console.log("\n🏥 Seeding Nairobi clinics, appointment slots & live queue...");
  const clinics = [
    {
      id: "c_mbagathi",
      data: {
        name: "Mbagathi Sub-County Hospital Outpatient",
        subCounty: "Kibra / Langata, Nairobi",
        address: "Mbagathi Way, Off Langata Road",
        openingHours: "08:00 - 17:00",
        totalSlotsToday: 24,
        availableSlotsToday: 12,
      },
      slotsCount: 5,
      tickets: [
        {
          id: "t_mbagathi_01",
          ticketNumber: "A001",
          patientId: "patient_external_01",
          status: "in_service",
          minutesAgo: 35,
          startedMinutesAgo: 5,
          reasonCode: "GENERAL_TRIAGE",
        },
        {
          id: "t_mbagathi_02",
          ticketNumber: "A002",
          patientId: "patient_chris",
          status: "waiting",
          minutesAgo: 25,
          reasonCode: "GENERAL_TRIAGE",
        },
        {
          id: "t_mbagathi_03",
          ticketNumber: "A003",
          patientId: "patient_amina",
          status: "waiting",
          minutesAgo: 15,
          reasonCode: "CHILD_WELFARE",
        },
        {
          id: "t_mbagathi_04",
          ticketNumber: "A004",
          patientId: "patient_external_02",
          status: "waiting",
          minutesAgo: 8,
          reasonCode: "ANTENATAL_CARE",
        },
      ],
    },
    {
      id: "c_westlands",
      data: {
        name: "Westlands Health Centre",
        subCounty: "Westlands, Nairobi",
        address: "Waiyaki Way, Next to Westlands Roundabout",
        openingHours: "08:30 - 16:30",
        totalSlotsToday: 16,
        availableSlotsToday: 6,
      },
      slotsCount: 4,
      tickets: [
        {
          id: "t_westlands_01",
          ticketNumber: "B001",
          patientId: "patient_external_03",
          status: "waiting",
          minutesAgo: 12,
          reasonCode: "GENERAL_TRIAGE",
        },
      ],
    },
    {
      id: "c_mama_lucy",
      data: {
        name: "Mama Lucy Kibaki Hospital Outpatient",
        subCounty: "Embakasi Central, Nairobi",
        address: "Kangundo Road, Kayole",
        openingHours: "24 Hours Triage",
        totalSlotsToday: 30,
        availableSlotsToday: 18,
      },
      slotsCount: 5,
      tickets: [
        {
          id: "t_mamalucy_01",
          ticketNumber: "C001",
          patientId: "patient_external_04",
          status: "called",
          minutesAgo: 40,
          startedMinutesAgo: 2,
          reasonCode: "EMERGENCY_TRIAGE",
        },
      ],
    },
  ];

  const now = new Date();

  for (const clinic of clinics) {
    const clinicRef = db.collection("clinics").doc(clinic.id);
    await clinicRef.set({
      ...clinic.data,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`   🏥 Clinic: ${clinic.data.name} (${clinic.id})`);

    // Seed Slots
    const slotsCol = clinicRef.collection("slots");
    for (let i = 0; i < clinic.slotsCount; i++) {
      const start = new Date(now);
      start.setHours(8 + Math.floor(i / 2), (i % 2) * 30, 0, 0);
      const end = new Date(start.getTime() + 30 * 60 * 1000);

      await slotsCol.doc(`slot_0${i}`).set({
        startTime: admin.firestore.Timestamp.fromDate(start),
        endTime: admin.firestore.Timestamp.fromDate(end),
        capacity: 5,
        bookedCount: i === 1 ? 5 : i, // slot 1 full for testing boundary
      });
    }
    console.log(`      ✓ Seeded ${clinic.slotsCount} appointment slots`);

    // Seed Queue Tickets
    const queueCol = clinicRef.collection("queue");
    for (const t of clinic.tickets) {
      const joinedAtDate = new Date(now.getTime() - t.minutesAgo * 60 * 1000);
      const serviceStartedAtDate = t.startedMinutesAgo
        ? new Date(now.getTime() - t.startedMinutesAgo * 60 * 1000)
        : null;

      await queueCol.doc(t.id).set({
        clinicId: clinic.id,
        patientId: t.patientId,
        ticketNumber: t.ticketNumber,
        status: t.status,
        joinedAt: admin.firestore.Timestamp.fromDate(joinedAtDate),
        ...(serviceStartedAtDate && {
          serviceStartedAt: admin.firestore.Timestamp.fromDate(serviceStartedAtDate),
        }),
        reasonCode: t.reasonCode,
      });
      console.log(`      ✓ Queue Ticket: #${t.ticketNumber} [${t.status}] for ${t.patientId}`);
    }
  }

  console.log("\n✅ Firestore Emulator seeded successfully!");
}

// Execute directly if run via CLI
if (require.main === module) {
  seedEmulator()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("❌ Seeding failed:", err);
      process.exit(1);
    });
}

