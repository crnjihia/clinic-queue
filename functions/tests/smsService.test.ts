// path: functions/tests/smsService.test.ts
import { expect } from "chai";
import { MockSmsService, getSmsService } from "../src/smsService";

describe("Africa's Talking SMS Integration & Mock Service", () => {
  describe("MockSmsService", () => {
    const smsService = new MockSmsService();

    it("should return successful SMS response for valid Kenyan recipient", async () => {
      const response = await smsService.sendSms({
        to: "0712345678",
        message: "Ticket A001: You are next in queue at Nairobi Clinic.",
        language: "en",
      });

      expect(response.status).to.equal("Success");
      expect(response.messageId).to.include("AT_SMS_");
      expect(response.recipient).to.equal("+254712345678");
      expect(response.cost).to.equal("KES 0.8000");
    });

    it("should return failure for test numbers ending in 999999", async () => {
      const response = await smsService.sendSms({
        to: "0799999999",
        message: "Failure test message",
      });

      expect(response.status).to.equal("Failed");
      expect(response.cost).to.equal("KES 0.0000");
    });
  });

  describe("Factory getSmsService", () => {
    it("should return MockSmsService when USE_MOCK_SMS is true", () => {
      process.env.USE_MOCK_SMS = "true";
      const service = getSmsService();
      expect(service).to.be.an.instanceOf(MockSmsService);
    });
  });
});
