// path: functions/tests/queueNotifications.test.ts
import { expect } from "chai";
import { evaluateAndSendQueueAlert } from "../src/queueNotifications";
import { MockSmsService } from "../src/smsService";
import { QueueTicketDoc } from "../src/types";

describe("evaluateAndSendQueueAlert", () => {
  const dummyTimestamp = {
    seconds: 1700000000,
    nanoseconds: 0,
    toDate: () => new Date(),
  } as any;

  const mockSmsService = new MockSmsService();

  it("skips notification if ticket status is not waiting", async () => {
    const ticketData: QueueTicketDoc = {
      clinicId: "c_mbagathi",
      patientId: "patient_1",
      ticketNumber: "A001",
      status: "done",
      joinedAt: dummyTimestamp,
      reasonCode: "TRIAGE",
    };

    const result = await evaluateAndSendQueueAlert(
      "c_mbagathi",
      "ticket_1",
      ticketData,
      {} as any,
      {} as any,
      mockSmsService
    );

    expect(result.sentFcm).to.be.false;
    expect(result.sentSms).to.be.false;
    expect(result.reason).to.include("not waiting");
  });

  it("calculates queue position accurately from firestore query snapshots", async () => {
    const mockWaitingDocs = [
      { id: "ticket_0", data: () => ({ joinedAt: dummyTimestamp }) },
      { id: "ticket_1", data: () => ({ joinedAt: dummyTimestamp }) },
      { id: "ticket_2", data: () => ({ joinedAt: dummyTimestamp }) },
      { id: "ticket_3", data: () => ({ joinedAt: dummyTimestamp }) },
    ];

    const mockFirestore: any = {
      collection: () => ({
        doc: () => ({
          collection: () => ({
            where: () => ({
              orderBy: () => ({
                get: async () => ({ docs: mockWaitingDocs }),
              }),
            }),
          }),
        }),
      }),
    };

    const ticketData: QueueTicketDoc = {
      clinicId: "c_mbagathi",
      patientId: "patient_3",
      ticketNumber: "A004",
      status: "waiting",
      joinedAt: dummyTimestamp,
      reasonCode: "TRIAGE",
    };

    // ticket_3 is at index 3 (3 people ahead), threshold is 2 -> should not send
    const result = await evaluateAndSendQueueAlert(
      "c_mbagathi",
      "ticket_3",
      ticketData,
      mockFirestore,
      {} as any,
      mockSmsService
    );

    expect(result.sentFcm).to.be.false;
    expect(result.sentSms).to.be.false;
    expect(result.position).to.equal(3);
    expect(result.reason).to.include("exceeds alert threshold");
  });

  it("sends FCM push alert and Africa's Talking SMS when position is <= 2", async () => {
    const mockWaitingDocs = [
      { id: "ticket_0", data: () => ({}) },
      { id: "ticket_1", data: () => ({}) }, // 1 person ahead!
    ];

    let messageSent: any = null;

    const mockFirestore: any = {
      collection: (col: string) => {
        if (col === "clinics") {
          return {
            doc: () => ({
              collection: () => ({
                where: () => ({
                  orderBy: () => ({
                    get: async () => ({ docs: mockWaitingDocs }),
                  }),
                }),
              }),
            }),
          };
        } else {
          // 'users' collection
          return {
            doc: (uid: string) => ({
              get: async () => ({
                exists: true,
                data: () => ({
                  phoneNumber: "+254712345678",
                  displayName: "Patient Chris",
                  role: "patient",
                  fcmTokens: ["fcm_token_device_abc"],
                  preferredLanguage: "sw",
                }),
              }),
            }),
          };
        }
      },
    };

    const mockMessaging: any = {
      sendEachForMulticast: async (payload: any) => {
        messageSent = payload;
        return { successCount: 1, failureCount: 0 };
      },
    };

    const ticketData: QueueTicketDoc = {
      clinicId: "c_mbagathi",
      patientId: "patient_1",
      ticketNumber: "A042",
      status: "waiting",
      joinedAt: dummyTimestamp,
      reasonCode: "TRIAGE",
    };

    const result = await evaluateAndSendQueueAlert(
      "c_mbagathi",
      "ticket_1",
      ticketData,
      mockFirestore,
      mockMessaging,
      mockSmsService
    );

    expect(result.sentFcm).to.be.true;
    expect(result.sentSms).to.be.true;
    expect(result.position).to.equal(1);
    expect(result.tokensCount).to.equal(1);
    expect(messageSent).to.not.be.null;
    expect(messageSent.notification.title).to.include("Ukaribu wa zamu yako");
  });
});
