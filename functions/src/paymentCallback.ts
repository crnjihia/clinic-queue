// path: functions/src/paymentCallback.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

export interface DarajaCallbackPayload {
  Body: {
    stkCallback: {
      MerchantRequestID: string;
      CheckoutRequestID: string;
      ResultCode: number; // 0 = Success
      ResultDesc: string;
      CallbackMetadata?: {
        Item: Array<{
          Name: string;
          Value?: string | number;
        }>;
      };
    };
  };
}

/**
 * Handles M-Pesa Express STK Push HTTP asynchronous callback from Safaricom Daraja.
 * Updates payment status document and clinic ticket payment status in Firestore.
 */
export async function processMpesaCallback(
  payload: DarajaCallbackPayload,
  firestore: FirebaseFirestore.Firestore = admin.firestore()
): Promise<{ ResultCode: number; ResultDesc: string }> {
  const stkCallback = payload?.Body?.stkCallback;
  if (!stkCallback) {
    throw new Error("Invalid M-Pesa callback payload format.");
  }

  const { CheckoutRequestID, MerchantRequestID, ResultCode, ResultDesc, CallbackMetadata } = stkCallback;
  const isSuccess = ResultCode === 0;

  let mpesaReceiptNumber = "";
  let amount = 0;
  let phoneNumber = "";

  if (isSuccess && CallbackMetadata?.Item) {
    for (const item of CallbackMetadata.Item) {
      if (item.Name === "MpesaReceiptNumber" && item.Value) {
        mpesaReceiptNumber = String(item.Value);
      } else if (item.Name === "Amount" && item.Value) {
        amount = Number(item.Value);
      } else if (item.Name === "PhoneNumber" && item.Value) {
        phoneNumber = String(item.Value);
      }
    }
  }

  // Find corresponding payment record in Firestore by checkoutRequestId
  const paymentsSnapshot = await firestore
    .collection("payments")
    .where("checkoutRequestId", "==", CheckoutRequestID)
    .limit(1)
    .get();

  if (!paymentsSnapshot.empty) {
    const paymentDocRef = paymentsSnapshot.docs[0].ref;
    const paymentData = paymentsSnapshot.docs[0].data();

    await paymentDocRef.update({
      status: isSuccess ? "completed" : "failed",
      mpesaReceiptNumber: mpesaReceiptNumber || null,
      amount: amount || paymentData.amount,
      phoneNumber: phoneNumber || paymentData.phoneNumber,
      failureReason: isSuccess ? null : ResultDesc,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update clinic queue ticket payment status
    if (paymentData.clinicId && paymentData.ticketId) {
      const ticketRef = firestore
        .collection("clinics")
        .doc(paymentData.clinicId)
        .collection("queue")
        .doc(paymentData.ticketId);

      await ticketRef.update({
        paymentStatus: isSuccess ? "completed" : "failed",
        mpesaCheckoutRequestId: CheckoutRequestID,
      });
    }
  }

  return { ResultCode: 0, ResultDesc: "Accepted" };
}

/**
 * Cloud HTTP Function exposed to receive Safaricom M-Pesa STK Push callbacks.
 */
export const onMpesaCallback = functions.https.onRequest(async (req, res) => {
  try {
    const response = await processMpesaCallback(req.body as DarajaCallbackPayload);
    res.status(200).json(response);
  } catch (error) {
    functions.logger.error("Error processing M-Pesa callback:", error);
    res.status(400).json({ ResultCode: 1, ResultDesc: "Rejected" });
  }
});
