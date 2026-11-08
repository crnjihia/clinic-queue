// path: functions/tests/mpesaService.test.ts
import { expect } from "chai";
import { MockMpesaService, normalizeKenyanPhone, getMpesaService } from "../src/mpesaService";

describe("M-Pesa Daraja Integration & Mock Service", () => {
  describe("normalizeKenyanPhone Utility", () => {
    it("should format standard +2547XXXXXXXX numbers correctly", () => {
      const result = normalizeKenyanPhone("+254712345678");
      expect(result).to.equal("254712345678");
    });

    it("should format local 07XXXXXXXX numbers to 2547XXXXXXXX", () => {
      const result = normalizeKenyanPhone("0712345678");
      expect(result).to.equal("254712345678");
    });

    it("should format local 01XXXXXXXX numbers to 2541XXXXXXXX", () => {
      const result = normalizeKenyanPhone("0112345678");
      expect(result).to.equal("254112345678");
    });

    it("should throw error for invalid phone numbers", () => {
      expect(() => normalizeKenyanPhone("12345")).to.throw(Error);
    });
  });

  describe("MockMpesaService", () => {
    const mpesaService = new MockMpesaService();

    it("should successfully initiate mock STK push with valid parameters", async () => {
      const response = await mpesaService.initiateStkPush({
        phoneNumber: "0712345678",
        amount: 500,
        accountReference: "TICKET-A001",
        transactionDesc: "Nairobi Clinic Consultation Fee",
      });

      expect(response.responseCode).to.equal("0");
      expect(response.checkoutRequestId).to.include("ws_CO_");
      expect(response.customerMessage).to.include("KES 500");
    });

    it("should return failure for test trigger phone numbers ending in 000000", async () => {
      const response = await mpesaService.initiateStkPush({
        phoneNumber: "0700000000",
        amount: 200,
        accountReference: "TICKET-FAIL",
        transactionDesc: "Failure Test",
      });

      expect(response.responseCode).to.equal("1");
      expect(response.customerMessage).to.include("Insufficient balance");
    });
  });

  describe("Factory getMpesaService", () => {
    it("should return MockMpesaService when USE_MOCK_PAYMENTS is true", () => {
      process.env.USE_MOCK_PAYMENTS = "true";
      const service = getMpesaService();
      expect(service).to.be.an.instanceOf(MockMpesaService);
    });
  });
});
