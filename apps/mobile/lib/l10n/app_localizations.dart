import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic Queue'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Nairobi Outpatient Appointments & Live Queues'**
  String get tagline;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline mode active. Showing cached queue updates.'**
  String get offlineBanner;

  /// No description provided for @navClinics.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get navClinics;

  /// No description provided for @navQueue.
  ///
  /// In en, this message translates to:
  /// **'Live Queue'**
  String get navQueue;

  /// No description provided for @navStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff Portal'**
  String get navStaff;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Clinic Queue'**
  String get authWelcome;

  /// No description provided for @authInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your Kenyan mobile number for quick sign-in'**
  String get authInstruction;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number (+254...)'**
  String get authPhoneLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Mobile'**
  String get authSignInButton;

  /// No description provided for @authInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Kenyan phone number (e.g. 0712 345 678)'**
  String get authInvalidPhone;

  /// No description provided for @authRolePatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get authRolePatient;

  /// No description provided for @authRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Clinical Staff'**
  String get authRoleStaff;

  /// No description provided for @clinicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nairobi Health Facilities'**
  String get clinicsTitle;

  /// No description provided for @clinicsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search clinic or sub-county...'**
  String get clinicsSearchHint;

  /// No description provided for @clinicSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} slots available today'**
  String clinicSlotsAvailable(int count);

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookingTitle;

  /// No description provided for @bookingSelectSlot.
  ///
  /// In en, this message translates to:
  /// **'Select Appointment Time'**
  String get bookingSelectSlot;

  /// No description provided for @bookingReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Consultation Reason'**
  String get bookingReasonLabel;

  /// No description provided for @bookingReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. General Consultation, Child Immunisation, Triage'**
  String get bookingReasonHint;

  /// No description provided for @bookingConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Join Queue'**
  String get bookingConfirmButton;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment confirmed! Ticket #{ticketNumber}'**
  String bookingSuccess(String ticketNumber);

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consultation Fee (KES {amount})'**
  String paymentTitle(double amount);

  /// No description provided for @paymentPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa Mobile Number (+254...)'**
  String get paymentPhoneLabel;

  /// No description provided for @paymentStkPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sending STK Push to {phone}. Please enter your M-Pesa PIN on your phone.'**
  String paymentStkPrompt(String phone);

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa payment received! Receipt #{receipt}'**
  String paymentSuccess(String receipt);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// No description provided for @queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Queue Status'**
  String get queueTitle;

  /// No description provided for @queueTicketNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket #{ticketNumber}'**
  String queueTicketNumber(String ticketNumber);

  /// No description provided for @queuePeopleAhead.
  ///
  /// In en, this message translates to:
  /// **'People ahead of you'**
  String get queuePeopleAhead;

  /// No description provided for @queueEstimatedWait.
  ///
  /// In en, this message translates to:
  /// **'Estimated wait time'**
  String get queueEstimatedWait;

  /// No description provided for @queueStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting in queue'**
  String get queueStatusWaiting;

  /// No description provided for @queueStatusCalled.
  ///
  /// In en, this message translates to:
  /// **'You have been called! Proceed to Consultation Room.'**
  String get queueStatusCalled;

  /// No description provided for @queueStatusInService.
  ///
  /// In en, this message translates to:
  /// **'Currently in consultation'**
  String get queueStatusInService;

  /// No description provided for @queueStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Consultation completed'**
  String get queueStatusDone;

  /// No description provided for @queueStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get queueStatusCancelled;

  /// No description provided for @queueCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ticket'**
  String get queueCancelButton;

  /// No description provided for @staffDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Triage Console'**
  String get staffDashboardTitle;

  /// No description provided for @staffCallNextButton.
  ///
  /// In en, this message translates to:
  /// **'Call Next Patient'**
  String get staffCallNextButton;

  /// No description provided for @staffStartServiceButton.
  ///
  /// In en, this message translates to:
  /// **'Start Consultation'**
  String get staffStartServiceButton;

  /// No description provided for @staffCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get staffCompleteButton;

  /// No description provided for @staffNoShowButton.
  ///
  /// In en, this message translates to:
  /// **'Mark No-Show'**
  String get staffNoShowButton;

  /// No description provided for @staffNoWaiting.
  ///
  /// In en, this message translates to:
  /// **'No patients currently waiting in queue.'**
  String get staffNoWaiting;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorDoubleBooking.
  ///
  /// In en, this message translates to:
  /// **'This slot was just taken by another patient. Please pick another.'**
  String get errorDoubleBooking;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
