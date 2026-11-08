// path: functions/src/mpesaService.ts
import { MpesaStkPushRequest, MpesaStkPushResponse } from "./types";

export interface IMpesaService {
  initiateStkPush(request: MpesaStkPushRequest): Promise<MpesaStkPushResponse>;
  formatPhoneNumber(phone: string): string;
}

/**
 * Normalizes Kenyan phone numbers to strict 2547XXXXXXXX or 2541XXXXXXXX format.
 */
export function normalizeKenyanPhone(phone: string): string {
  const cleaned = phone.replace(/\D/g, "");
  if (cleaned.startsWith("254") && cleaned.length === 12) {
    return cleaned;
  }
  if (cleaned.startsWith("0") && cleaned.length === 10) {
    return `254${cleaned.substring(1)}`;
  }
  if (cleaned.length === 9 && (cleaned.startsWith("7") || cleaned.startsWith("1"))) {
    return `254${cleaned}`;
  }
  throw new Error(`Invalid Kenyan phone number format: ${phone}. Expected +2547XXXXXXXX or +2541XXXXXXXX.`);
}

/**
 * Mock M-Pesa Daraja STK Push Service for local development and sandbox tests.
 * Selected when process.env.USE_MOCK_PAYMENTS === "true" or credentials are not set.
 */
export class MockMpesaService implements IMpesaService {
  public formatPhoneNumber(phone: string): string {
    return normalizeKenyanPhone(phone);
  }

  public async initiateStkPush(request: MpesaStkPushRequest): Promise<MpesaStkPushResponse> {
    const formattedPhone = this.formatPhoneNumber(request.phoneNumber);
    const mockCheckoutId = `ws_CO_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    const mockMerchantId = `MOCK_REQ_${Date.now()}`;

    // Simulate invalid phone number check
    if (formattedPhone.endsWith("000000")) {
      return {
        merchantRequestId: mockMerchantId,
        checkoutRequestId: mockCheckoutId,
        responseCode: "1",
        responseDescription: "The balance is insufficient for the transaction",
        customerMessage: "STK Push failed: Insufficient balance.",
      };
    }

    return {
      merchantRequestId: mockMerchantId,
      checkoutRequestId: mockCheckoutId,
      responseCode: "0",
      responseDescription: "Success. Request accepted for processing",
      customerMessage: `STK Push sent to ${formattedPhone}. Please enter your M-Pesa PIN for KES ${request.amount}.`,
    };
  }
}

/**
 * Real Safaricom Daraja STK Push Express Implementation for Staging/Production.
 */
export class DarajaMpesaService implements IMpesaService {
  private consumerKey: string;
  private consumerSecret: string;
  private passkey: string;
  private shortCode: string;
  private baseUrl: string;

  constructor(
    consumerKey = process.env.MPESA_CONSUMER_KEY || "",
    consumerSecret = process.env.MPESA_CONSUMER_SECRET || "",
    passkey = process.env.MPESA_PASSKEY || "",
    shortCode = process.env.MPESA_SHORTCODE || "174379",
    isProduction = process.env.MPESA_ENV === "production"
  ) {
    this.consumerKey = consumerKey;
    this.consumerSecret = consumerSecret;
    this.passkey = passkey;
    this.shortCode = shortCode;
    this.baseUrl = isProduction
      ? "https://api.safaricom.co.ke"
      : "https://sandbox.safaricom.co.ke";
  }

  public formatPhoneNumber(phone: string): string {
    return normalizeKenyanPhone(phone);
  }

  private async getAccessToken(): Promise<string> {
    if (!this.consumerKey || !this.consumerSecret) {
      throw new Error("M-Pesa Consumer Key and Secret must be configured in environment variables.");
    }

    const auth = Buffer.from(`${this.consumerKey}:${this.consumerSecret}`).toString("base64");
    const response = await fetch(`${this.baseUrl}/oauth/v1/generate?grant_type=client_credentials`, {
      headers: { Authorization: `Basic ${auth}` },
    });

    if (!response.ok) {
      throw new Error(`Failed to generate M-Pesa access token: ${response.statusText}`);
    }

    const data = await response.json() as { access_token: string };
    return data.access_token;
  }

  public async initiateStkPush(request: MpesaStkPushRequest): Promise<MpesaStkPushResponse> {
    const accessToken = await this.getAccessToken();
    const formattedPhone = this.formatPhoneNumber(request.phoneNumber);
    const timestamp = new Date()
      .toISOString()
      .replace(/[^0-9]/g, "")
      .slice(0, 14);

    const password = Buffer.from(`${this.shortCode}${this.passkey}${timestamp}`).toString("base64");
    const callbackUrl = request.callbackUrl || process.env.MPESA_CALLBACK_URL || "https://example.com/mpesa/callback";

    const payload = {
      BusinessShortCode: this.shortCode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: Math.round(request.amount),
      PartyA: formattedPhone,
      PartyB: this.shortCode,
      PhoneNumber: formattedPhone,
      CallBackURL: callbackUrl,
      AccountReference: request.accountReference,
      TransactionDesc: request.transactionDesc,
    };

    const response = await fetch(`${this.baseUrl}/mpesa/stkpush/v1/processrequest`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Daraja STK Push failed with status ${response.status}: ${errorText}`);
    }

    const data = await response.json() as {
      MerchantRequestID: string;
      CheckoutRequestID: string;
      ResponseCode: string;
      ResponseDescription: string;
      CustomerMessage: string;
    };

    return {
      merchantRequestId: data.MerchantRequestID,
      checkoutRequestId: data.CheckoutRequestID,
      responseCode: data.ResponseCode,
      responseDescription: data.ResponseDescription,
      customerMessage: data.CustomerMessage,
    };
  }
}

/**
 * Factory function selecting Mock or Real M-Pesa Service based on environment config.
 */
export function getMpesaService(): IMpesaService {
  if (process.env.USE_MOCK_PAYMENTS === "true" || !process.env.MPESA_CONSUMER_KEY) {
    return new MockMpesaService();
  }
  return new DarajaMpesaService();
}
