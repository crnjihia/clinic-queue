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
}

export interface UserDoc {
  phoneNumber: string;
  displayName: string;
  role: "patient" | "staff";
  fcmTokens?: string[];
}

export interface NotificationPayload {
  title: string;
  body: string;
  ticketNumber: string;
  clinicId: string;
}
