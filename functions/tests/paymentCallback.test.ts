// path: functions/tests/paymentCallback.test.ts
import { expect } from "chai";
import { processMpesaCallback, DarajaCallbackPayload } from "../src/paymentCallback";

describe("M-Pesa Payment Callback Processing", () => {
  it("should parse successful M-Pesa STK Push callback payload", async () => {
    const payload: DarajaCallbackPayload = {
      Body: {
        stkCallback: {
          MerchantRequestID: "MOCK_MERCHANT_123",
          CheckoutRequestID: "ws_CO_123456789",
          ResultCode: 0,
          ResultDesc: "The service request has been processed successfully.",
          CallbackMetadata: {
            Item: [
              { Name: "Amount", Value: 500 },
              { Name: "MpesaReceiptNumber", Value: "QKH1234567" },
              { Name: "TransactionDate", Value: 20240101120000 },
              { Name: "PhoneNumber", Value: 254712345678 },
            ],
          },
        },
      },
    };

    // Fake Firestore interface for unit testing processMpesaCallback payload parser
    const mockFirestore: any = {
      collection: () => ({
        where: () => ({
          limit: () => ({
            get: async () => ({
              empty: true,
              docs: [],
            }),
          }),
        }),
      }),
    };

    const response = await processMpesaCallback(payload, mockFirestore);
    expect(response.ResultCode).to.equal(0);
    expect(response.ResultDesc).to.equal("Accepted");
  });

  it("should throw an error for malformed callback payloads", async () => {
    try {
      await processMpesaCallback({} as any, {} as any);
      expect.fail("Should have thrown error");
    } catch (err: any) {
      expect(err.message).to.include("Invalid M-Pesa callback payload");
    }
  });
});
