// path: functions/src/queueNotifications.ts
import * as admin from "firebase-admin";
import { getSmsService, ISmsService } from "./smsService";
import { QueueTicketDoc, UserDoc } from "./types";

export interface NotificationResult {
  sentFcm: boolean;
  sentSms: boolean;
  position: number;
  tokensCount: number;
  smsMessageId?: string;
  reason?: string;
}

/**
 * Calculates patient position in the clinic queue and dispatches FCM push alerts
 * and Africa's Talking SMS notifications when position is <= 2 ("You are next!").
 */
export async function evaluateAndSendQueueAlert(
  clinicId: string,
  ticketId: string,
  ticketData: QueueTicketDoc,
  firestore: FirebaseFirestore.Firestore = admin.firestore(),
  messaging: admin.messaging.Messaging = admin.messaging(),
  smsService: ISmsService = getSmsService()
): Promise<NotificationResult> {
  // Only evaluate active waiting tickets
  if (ticketData.status !== "waiting") {
    return { sentFcm: false, sentSms: false, position: -1, tokensCount: 0, reason: "Ticket is not waiting" };
  }

  // Fetch all waiting tickets ordered by joinedAt asc
  const waitingSnapshot = await firestore
    .collection("clinics")
    .doc(clinicId)
    .collection("queue")
    .where("status", "==", "waiting")
    .orderBy("joinedAt", "asc")
    .get();

  const ticketIndex = waitingSnapshot.docs.findIndex((doc) => doc.id === ticketId);

  if (ticketIndex < 0) {
    return { sentFcm: false, sentSms: false, position: -1, tokensCount: 0, reason: "Ticket not found in queue" };
  }

  const peopleAhead = ticketIndex; // 0 = next, 1 = 1 person ahead, 2 = 2 people ahead

  if (peopleAhead > 2) {
    return {
      sentFcm: false,
      sentSms: false,
      position: peopleAhead,
      tokensCount: 0,
      reason: `People ahead (${peopleAhead}) exceeds alert threshold (2)`,
    };
  }

  // Retrieve patient user record for FCM tokens & phone number
  const userDocRef = firestore.collection("users").doc(ticketData.patientId);
  const userSnapshot = await userDocRef.get();

  if (!userSnapshot.exists) {
    return { sentFcm: false, sentSms: false, position: peopleAhead, tokensCount: 0, reason: "Patient user record not found" };
  }

  const userData = userSnapshot.data() as UserDoc;
  const fcmTokens = userData.fcmTokens ?? [];
  const isSwahili = userData.preferredLanguage === "sw";

  // Construct localized notification content
  const title = isSwahili
    ? (peopleAhead === 0 ? "Wewe ndiye unayefuata! (Foleni wa Kliniki)" : `Ukaribu wa zamu yako (${peopleAhead} mbele)`)
    : (peopleAhead === 0 ? "You are next! (Clinic Queue)" : `Almost your turn (${peopleAhead} ahead)`);

  const body = isSwahili
    ? (peopleAhead === 0
      ? `Tiketi #${ticketData.ticketNumber}: Tafadhali ingia katika chumba cha huduma sasa.`
      : `Tiketi #${ticketData.ticketNumber}: Kuna mtu ${peopleAhead} pekee mbele yako. Tafadhali kaa karibu.`)
    : (peopleAhead === 0
      ? `Ticket #${ticketData.ticketNumber}: Please proceed to the clinic triage/consultation bay now.`
      : `Ticket #${ticketData.ticketNumber}: Only ${peopleAhead} patient ahead of you. Please stay close to the waiting bay.`);

  let sentFcm = false;
  if (fcmTokens.length > 0) {
    const payload: admin.messaging.MulticastMessage = {
      tokens: fcmTokens,
      notification: { title, body },
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
        payload: { aps: { sound: "default", badge: 1 } },
      },
    };

    try {
      await messaging.sendEachForMulticast(payload);
      sentFcm = true;
    } catch (err) {
      // FCM dispatch error handled gracefully
    }
  }

  // Dispatch Africa's Talking SMS fallback if phone number exists
  let sentSms = false;
  let smsMessageId: string | undefined;

  if (userData.phoneNumber) {
    try {
      const smsRes = await smsService.sendSms({
        to: userData.phoneNumber,
        message: `${title}\n${body}`,
        language: userData.preferredLanguage || "en",
      });
      sentSms = smsRes.status === "Success";
      smsMessageId = smsRes.messageId;
    } catch (err) {
      // SMS dispatch error handled gracefully
    }
  }

  return {
    sentFcm,
    sentSms,
    position: peopleAhead,
    tokensCount: fcmTokens.length,
    smsMessageId,
  };
}
