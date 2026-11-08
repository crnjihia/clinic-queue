// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clinic Queue';

  @override
  String get tagline => 'Nairobi Outpatient Appointments & Live Queues';

  @override
  String get offlineBanner =>
      'Offline mode active. Showing cached queue updates.';

  @override
  String get navClinics => 'Clinics';

  @override
  String get navQueue => 'Live Queue';

  @override
  String get navStaff => 'Staff Portal';

  @override
  String get authWelcome => 'Welcome to Clinic Queue';

  @override
  String get authInstruction =>
      'Enter your Kenyan mobile number for quick sign-in';

  @override
  String get authPhoneLabel => 'Mobile Number (+254...)';

  @override
  String get authSignInButton => 'Sign In with Mobile';

  @override
  String get authInvalidPhone =>
      'Please enter a valid Kenyan phone number (e.g. 0712 345 678)';

  @override
  String get authRolePatient => 'Patient';

  @override
  String get authRoleStaff => 'Clinical Staff';

  @override
  String get clinicsTitle => 'Nairobi Health Facilities';

  @override
  String get clinicsSearchHint => 'Search clinic or sub-county...';

  @override
  String clinicSlotsAvailable(int count) {
    return '$count slots available today';
  }

  @override
  String get bookingTitle => 'Book Appointment';

  @override
  String get bookingSelectSlot => 'Select Appointment Time';

  @override
  String get bookingReasonLabel => 'Consultation Reason';

  @override
  String get bookingReasonHint =>
      'e.g. General Consultation, Child Immunisation, Triage';

  @override
  String get bookingConfirmButton => 'Confirm & Join Queue';

  @override
  String bookingSuccess(String ticketNumber) {
    return 'Appointment confirmed! Ticket #$ticketNumber';
  }

  @override
  String paymentTitle(double amount) {
    return 'Consultation Fee (KES $amount)';
  }

  @override
  String get paymentPhoneLabel => 'M-Pesa Mobile Number (+254...)';

  @override
  String paymentStkPrompt(String phone) {
    return 'Sending STK Push to $phone. Please enter your M-Pesa PIN on your phone.';
  }

  @override
  String paymentSuccess(String receipt) {
    return 'M-Pesa payment received! Receipt #$receipt';
  }

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get queueTitle => 'Live Queue Status';

  @override
  String queueTicketNumber(String ticketNumber) {
    return 'Ticket #$ticketNumber';
  }

  @override
  String get queuePeopleAhead => 'People ahead of you';

  @override
  String get queueEstimatedWait => 'Estimated wait time';

  @override
  String get queueStatusWaiting => 'Waiting in queue';

  @override
  String get queueStatusCalled =>
      'You have been called! Proceed to Consultation Room.';

  @override
  String get queueStatusInService => 'Currently in consultation';

  @override
  String get queueStatusDone => 'Consultation completed';

  @override
  String get queueStatusCancelled => 'Appointment cancelled';

  @override
  String get queueCancelButton => 'Cancel Ticket';

  @override
  String get staffDashboardTitle => 'Staff Triage Console';

  @override
  String get staffCallNextButton => 'Call Next Patient';

  @override
  String get staffStartServiceButton => 'Start Consultation';

  @override
  String get staffCompleteButton => 'Mark Completed';

  @override
  String get staffNoShowButton => 'Mark No-Show';

  @override
  String get staffNoWaiting => 'No patients currently waiting in queue.';

  @override
  String get errorGeneric => 'An unexpected error occurred. Please try again.';

  @override
  String get errorDoubleBooking =>
      'This slot was just taken by another patient. Please pick another.';
}
