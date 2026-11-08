// path: functions/src/smsService.ts
import { normalizeKenyanPhone } from "./mpesaService";
import { SmsRequest, SmsResponse } from "./types";

export interface ISmsService {
  sendSms(request: SmsRequest): Promise<SmsResponse>;
}

/**
 * Mock Africa's Talking SMS Service for offline local development and automated testing.
 * Enabled when process.env.USE_MOCK_SMS === "true" or AT credentials are not set.
 */
export class MockSmsService implements ISmsService {
  public async sendSms(request: SmsRequest): Promise<SmsResponse> {
    const formattedPhone = normalizeKenyanPhone(request.to);
    const mockMessageId = `AT_SMS_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

    // Simulate SMS failure for invalid numbers ending in 999999
    if (formattedPhone.endsWith("999999")) {
      return {
        status: "Failed",
        messageId: mockMessageId,
        cost: "KES 0.0000",
        recipient: `+${formattedPhone}`,
      };
    }

    return {
      status: "Success",
      messageId: mockMessageId,
      cost: "KES 0.8000",
      recipient: `+${formattedPhone}`,
    };
  }
}

/**
 * Real Africa's Talking SMS Service for Staging/Production deployment in Kenya.
 */
export class AfricasTalkingSmsService implements ISmsService {
  private apiKey: string;
  private username: string;
  private senderId?: string;
  private baseUrl: string;

  constructor(
    apiKey = process.env.AT_API_KEY || "",
    username = process.env.AT_USERNAME || "sandbox",
    senderId = process.env.AT_SENDER_ID,
    isProduction = process.env.AT_ENV === "production"
  ) {
    this.apiKey = apiKey;
    this.username = username;
    this.senderId = senderId;
    this.baseUrl = isProduction
      ? "https://api.africastalking.com/version1/messaging"
      : "https://api.sandbox.africastalking.com/version1/messaging";
  }

  public async sendSms(request: SmsRequest): Promise<SmsResponse> {
    if (!this.apiKey || !this.username) {
      throw new Error("Africa's Talking API key and username must be configured in environment variables.");
    }

    const formattedPhone = `+${normalizeKenyanPhone(request.to)}`;
    const params = new URLSearchParams();
    params.append("username", this.username);
    params.append("to", formattedPhone);
    params.append("message", request.message);
    if (this.senderId) {
      params.append("from", this.senderId);
    }

    const response = await fetch(this.baseUrl, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        apiKey: this.apiKey,
      },
      body: params.toString(),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Africa's Talking SMS failed with status ${response.status}: ${errorText}`);
    }

    const data = await response.json() as {
      SMSMessageData: {
        Message: string;
        Recipients: Array<{
          statusCode: number;
          number: string;
          status: string;
          cost: string;
          messageId: string;
        }>;
      };
    };

    const recipient = data.SMSMessageData.Recipients[0];
    const isSuccess = recipient && (recipient.status === "Success" || recipient.statusCode === 101);

    return {
      status: isSuccess ? "Success" : "Failed",
      messageId: recipient ? recipient.messageId : "UNKNOWN",
      cost: recipient ? recipient.cost : "KES 0.0000",
      recipient: recipient ? recipient.number : formattedPhone,
    };
  }
}

/**
 * Factory function selecting Mock or Real SMS Service based on environment config.
 */
export function getSmsService(): ISmsService {
  if (process.env.USE_MOCK_SMS === "true" || !process.env.AT_API_KEY) {
    return new MockSmsService();
  }
  return new AfricasTalkingSmsService();
}
