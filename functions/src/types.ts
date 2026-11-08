// path: functions/src/types.ts
export type TicketStatus = "waiting" | "called" | "in_service" | "done" | "no_show" | "cancelled";

export interface QueueTicketDoc {
  clinicId: string;
  patientId: string;
  ticketNumber: string;
  status: TicketStatus;
  joinedAt: FirebaseFirestore.Timestamp;
  serviceStartedAt?: FirebaseFirestore.Timestamp;
  serviceCompletedAt?: FirebaseFirestore.Timestamp;
  reasonCode: string;
  paymentStatus?: "pending" | "completed" | "failed";
  mpesaCheckoutRequestId?: string;
}

export interface UserDoc {
  phoneNumber: string;
  displayName: string;
  role: "patient" | "staff";
  fcmTokens?: string[];
  preferredLanguage?: "en" | "sw";
}

export interface NotificationPayload {
  title: string;
  body: string;
  ticketNumber: string;
  clinicId: string;
}

export interface MpesaStkPushRequest {
  phoneNumber: string; // Formatted +2547XXXXXXXX or 2547XXXXXXXX
  amount: number; // KES
  accountReference: string; // e.g. TICKET-A001
  transactionDesc: string; // e.g. Clinic consultation fee
  callbackUrl?: string;
}

export interface MpesaStkPushResponse {
  merchantRequestId: string;
  checkoutRequestId: string;
  responseCode: string; // "0" indicates success
  responseDescription: string;
  customerMessage: string;
}

export interface SmsRequest {
  to: string; // +2547XXXXXXXX
  message: string;
  language?: "en" | "sw";
}

export interface SmsResponse {
  status: "Success" | "Failed";
  messageId: string;
  cost: string; // e.g. "KES 0.8000"
  recipient: string;
}

export interface PaymentStatusDoc {
  id: string;
  ticketId: string;
  clinicId: string;
  patientId: string;
  amount: number; // KES
  phoneNumber: string;
  checkoutRequestId: string;
  merchantRequestId: string;
  status: "pending" | "completed" | "failed";
  mpesaReceiptNumber?: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  failureReason?: string;
}
