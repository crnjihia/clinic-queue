// path: functions/src/index.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

import { evaluateAndSendQueueAlert } from "./queueNotifications";
import { onMpesaCallback } from "./paymentCallback";
import { QueueTicketDoc } from "./types";

export { onMpesaCallback };

/**
 * Cloud Function triggered on any creation or update in clinics/{clinicId}/queue/{ticketId}
 * Evaluates queue position and dispatches FCM push alerts and SMS notifications to patients.
 */
export const onQueueTicketWritten = functions.firestore
  .document("clinics/{clinicId}/queue/{ticketId}")
  .onWrite(async (change, context) => {
    const { clinicId, ticketId } = context.params;

    // Document deletion: nothing to notify
    if (!change.after.exists) {
      functions.logger.info(`Ticket ${ticketId} in clinic ${clinicId} deleted.`);
      return null;
    }

    const ticketData = change.after.data() as QueueTicketDoc;

    try {
      const result = await evaluateAndSendQueueAlert(clinicId, ticketId, ticketData);
      functions.logger.info(
        `Queue alert evaluation for ticket ${ticketId}: ` +
        `fcmSent=${result.sentFcm}, smsSent=${result.sentSms}, position=${result.position}, tokens=${result.tokensCount}`
      );
      return result;
    } catch (error) {
      functions.logger.error(`Failed to process queue notification for ${ticketId}:`, error);
      return null;
    }
  });
