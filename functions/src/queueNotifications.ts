// path: functions/src/queueNotifications.ts
import * as admin from "firebase-admin";
import { QueueTicketDoc, UserDoc } from "./types";

export interface PushResult {
  sent: boolean;
  position: number;
  tokensCount: number;
  reason?: string;
}

/**
 * Calculates patient position in the clinic queue and sends an FCM push alert
 * if their position has reached 1 or 2 ("You are next!").
 */
export async function evaluateAndSendQueueAlert(
  clinicId: string,
  ticketId: string,
  ticketData: QueueTicketDoc,
  firestore: FirebaseFirestore.Firestore = admin.firestore(),
  messaging: admin.messaging.Messaging = admin.messaging()
): Promise<PushResult> {
  // Only evaluate active waiting tickets
  if (ticketData.status !== "waiting") {
    return { sent: false, position: -1, tokensCount: 0, reason: "Ticket is not waiting" };
  }

  // Fetch all waiting tickets ordered by joinedAt
  const waitingSnapshot = await firestore
    .collection("clinics")
    .doc(clinicId)
    .collection("queue")
    .where("status", "==", "waiting")
    .orderBy("joinedAt", "asc")
    .get();

  const ticketIndex = waitingSnapshot.docs.findIndex((doc) => doc.id === ticketId);

  if (ticketIndex < 0) {
    return { sent: false, position: -1, tokensCount: 0, reason: "Ticket not found in queue" };
  }

  const peopleAhead = ticketIndex; // 0 = next, 1 = 1 person ahead, 2 = 2 people ahead

  // Alert condition: 0, 1, or 2 people ahead
  if (peopleAhead > 2) {
    return {
      sent: false,
      position: peopleAhead,
      tokensCount: 0,
      reason: `People ahead (${peopleAhead}) exceeds alert threshold (2)`,
    };
  }

  // Retrieve patient FCM tokens
  const userDocRef = firestore.collection("users").doc(ticketData.patientId);
  const userSnapshot = await userDocRef.get();

  if (!userSnapshot.exists) {
    return { sent: false, position: peopleAhead, tokensCount: 0, reason: "Patient user record not found" };
  }

  const userData = userSnapshot.data() as UserDoc;
  const fcmTokens = userData.fcmTokens ?? [];

  if (fcmTokens.length === 0) {
    return { sent: false, position: peopleAhead, tokensCount: 0, reason: "No FCM tokens registered for patient" };
  }

  const title = peopleAhead === 0
    ? "You are next! (Foleni wa Kliniki)"
    : `Almost your turn (${peopleAhead} ahead)`;

  const body = peopleAhead === 0
    ? `Ticket #${ticketData.ticketNumber}: Please proceed to the clinic triage/consultation bay now.`
    : `Ticket #${ticketData.ticketNumber}: Only ${peopleAhead} patient ahead of you. Please stay close to the waiting bay.`;

  const payload: admin.messaging.MulticastMessage = {
    tokens: fcmTokens,
    notification: {
      title,
      body,
    },
    data: {
      ticketId,
      ticketNumber: ticketData.ticketNumber,
      clinicId,
      peopleAhead: peopleAhead.toString(),
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    android: {
      priority: "high",
      notification: {
        channelId: "clinic_queue_high_importance",
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  await messaging.sendEachForMulticast(payload);

  return {
    sent: true,
    position: peopleAhead,
    tokensCount: fcmTokens.length,
  };
}
