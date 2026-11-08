// path: apps/mobile/lib/core/router/route_names.dart
class RouteNames {
  RouteNames._();

  static const String auth = '/auth';
  static const String clinics = '/clinics';
  static const String slotPicker = '/clinics/:clinicId/slots';
  static const String ticketConfirmation = '/booking/confirmation';
  static const String liveQueue = '/queue';
  static const String staffDashboard = '/staff';
  static const String settings = '/settings';

  // Sub-routes / helpers
  static String slotPickerPath(String clinicId) => '/clinics/$clinicId/slots';
}
