// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Foleni wa Kliniki';

  @override
  String get tagline => 'Miadi ya Kliniki na Ufuatiliaji wa Foleni Nairobi';

  @override
  String get offlineBanner =>
      'Hali ya nje ya mtandao. Inaonyesha data iliyohifadhiwa.';

  @override
  String get navClinics => 'Kliniki';

  @override
  String get navQueue => 'Foleni Moja kwa Moja';

  @override
  String get navStaff => 'Sehemu ya Wahudumu';

  @override
  String get authWelcome => 'Karibu Foleni wa Kliniki';

  @override
  String get authInstruction =>
      'Weka nambari yako ya simu ya Kenya ili kuingia';

  @override
  String get authPhoneLabel => 'Nambari ya Simu (+254...)';

  @override
  String get authSignInButton => 'Ingia kwa Simu';

  @override
  String get authInvalidPhone =>
      'Tafadhali weka nambari halali ya Kenya (mf. 0712 345 678)';

  @override
  String get authRolePatient => 'Mgonjwa';

  @override
  String get authRoleStaff => 'Mhudumu wa Kliniki';

  @override
  String get clinicsTitle => 'Vituo vya Afya Nairobi';

  @override
  String get clinicsSearchHint => 'Tafuta kliniki au eneo...';

  @override
  String clinicSlotsAvailable(int count) {
    return 'Nafasi $count zinapatikana leo';
  }

  @override
  String get bookingTitle => 'Weka Miadi';

  @override
  String get bookingSelectSlot => 'Chagua Muda wa Miadi';

  @override
  String get bookingReasonLabel => 'Sababu ya Ushauri';

  @override
  String get bookingReasonHint =>
      'mf. Uchunguzi wa Jumla, Chanjo ya Mtoto, Huduma ya Kwanza';

  @override
  String get bookingConfirmButton => 'Thibitisha & Jiunge na Foleni';

  @override
  String bookingSuccess(String ticketNumber) {
    return 'Miadi imethibitishwa! Tiketi #$ticketNumber';
  }

  @override
  String paymentTitle(double amount) {
    return 'Ada ya Ushauri (KES $amount)';
  }

  @override
  String get paymentPhoneLabel => 'Nambari ya M-Pesa (+254...)';

  @override
  String paymentStkPrompt(String phone) {
    return 'Inatuma STK Push kwa $phone. Tafadhali weka PIN ya M-Pesa kwenye simu yako.';
  }

  @override
  String paymentSuccess(String receipt) {
    return 'Malipo ya M-Pesa yamepokelewa! Risiti #$receipt';
  }

  @override
  String get paymentFailed => 'Malipo yamefeli. Tafadhali jaribu tena.';

  @override
  String get queueTitle => 'Hali ya Foleni';

  @override
  String queueTicketNumber(String ticketNumber) {
    return 'Tiketi #$ticketNumber';
  }

  @override
  String get queuePeopleAhead => 'Watu walio mbele yako';

  @override
  String get queueEstimatedWait => 'Muda unaokadiriwa kusubiri';

  @override
  String get queueStatusWaiting => 'Unasubiri kwenye foleni';

  @override
  String get queueStatusCalled =>
      'Umeitwa! Tafadhali ingia chumba cha daktari.';

  @override
  String get queueStatusInService => 'Ushauri unaendelea';

  @override
  String get queueStatusDone => 'Ushauri umekamilika';

  @override
  String get queueStatusCancelled => 'Miadi imefutiliwa mbali';

  @override
  String get queueCancelButton => 'Ghairi Tiketi';

  @override
  String get staffDashboardTitle => 'Dashibodi ya Wahudumu';

  @override
  String get staffCallNextButton => 'Ita Mgonjwa Anayefuata';

  @override
  String get staffStartServiceButton => 'Anza Ushauri';

  @override
  String get staffCompleteButton => 'Weka Imekamilika';

  @override
  String get staffNoShowButton => 'Hakufika (No-Show)';

  @override
  String get staffNoWaiting => 'Hakuna wagonjwa wanaosubiri kwa sasa.';

  @override
  String get errorGeneric => 'Hitilafu imetokea. Tafadhali jaribu tena.';

  @override
  String get errorDoubleBooking =>
      'Nafasi hii imechukuliwa na mgonjwa mwingine. Tafadhali chagua nyingine.';
}
