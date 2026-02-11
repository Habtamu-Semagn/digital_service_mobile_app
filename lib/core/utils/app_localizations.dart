import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Getters for common strings
  String get appName => translate('appName');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgotPassword');
  String get loginButton => translate('loginButton');
  String get loggingIn => translate('loggingIn');
  String get invalidEmail => translate('invalidEmail');
  String get invalidPassword => translate('invalidPassword');
  String get loginError => translate('loginError');
  
  String get dashboard => translate('dashboard');
  String get services => translate('services');
  String get myRequests => translate('myRequests');
  String get notifications => translate('notifications');
  String get profile => translate('profile');
  String get settings => translate('settings');
  
  String get serviceMode => translate('serviceMode');
  String get online => translate('online');
  String get queue => translate('queue');
  String get appointment => translate('appointment');
  
  String get helpDesk => translate('helpDesk');
  String get serviceDetails => translate('serviceDetails');
  String get requiredDocuments => translate('requiredDocuments');
  String get proceedOnline => translate('proceedOnline');
  String get takeQueueNumber => translate('takeQueueNumber');
  String get bookAppointment => translate('bookAppointment');
  String get appointmentBooked => translate('appointmentBooked');
  String get selectTimeSlot => translate('selectTimeSlot');
  String get confirmBooking => translate('confirmBooking');
  String get estimatedTime => translate('estimatedTime');
  
  String get queueNumber => translate('queueNumber');
  String get yourQueueNumber => translate('yourQueueNumber');
  String get position => translate('position');
  String get estimatedWait => translate('estimatedWait');
  String get queueStatus => translate('queueStatus');
  String get waiting => translate('waiting');
  String get called => translate('called');
  String get inService => translate('inService');
  String get completed => translate('completed');
  String get cancelled => translate('cancelled');
  String get noShow => translate('noShow');
  
  String get appointments => translate('appointments');
  String get selectDate => translate('selectDate');
  String get selectTime => translate('selectTime');
  String get availableSlots => translate('availableSlots');
  String get confirmAppointment => translate('confirmAppointment');
  String get cancelAppointment => translate('cancelAppointment');
  String get rescheduleAppointment => translate('rescheduleAppointment');
  String get appointmentConfirmed => translate('appointmentConfirmed');
  String get confirmationCode => translate('confirmationCode');
  String get appointmentDate => translate('appointmentDate');
  String get appointmentTime => translate('appointmentTime');
  
  String get requests => translate('requests');
  String get requestStatus => translate('requestStatus');
  String get inProgress => translate('inProgress');
  String get rejected => translate('rejected');
  String get allRequests => translate('allRequests');
  String get filterByStatus => translate('filterByStatus');
  String get requestDetails => translate('requestDetails');
  String get timeline => translate('timeline');
  
  String get notificationsList => translate('notificationsList');
  String get markAsRead => translate('markAsRead');
  String get markAllAsRead => translate('markAllAsRead');
  String get noNotifications => translate('noNotifications');
  String get queueIssued => translate('queueIssued');
  String get queueCalled => translate('queueCalled');
  String get appointmentConfirmedNotif => translate('appointmentConfirmedNotif');
  String get appointmentReminder => translate('appointmentReminder');
  String get statusChanged => translate('statusChanged');
  
  String get language => translate('language');
  String get english => translate('english');
  String get amharic => translate('amharic');
  String get changeLanguage => translate('changeLanguage');
  
  String get error => translate('error');
  String get success => translate('success');
  String get warning => translate('warning');
  String get info => translate('info');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get retry => translate('retry');
  String get close => translate('close');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get refresh => translate('refresh');
  String get loading => translate('loading');
  String get noData => translate('noData');
  String get pullToRefresh => translate('pullToRefresh');
  
  String get networkError => translate('networkError');
  String get serverError => translate('serverError');
  String get sessionExpired => translate('sessionExpired');
  String get unexpectedError => translate('unexpectedError');
  
  String get yes => translate('yes');
  String get no => translate('no');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get apply => translate('apply');
  String get reset => translate('reset');
  
  String get fullName => translate('fullName');
  String get phoneNumber => translate('phoneNumber');
  String get updateProfile => translate('updateProfile');
  String get profileUpdated => translate('profileUpdated');
  
  String get noActiveQueue => translate('noActiveQueue');
  String get noUpcomingAppointments => translate('noUpcomingAppointments');
  String get noRequests => translate('noRequests');
  
  String get slotNotAvailable => translate('slotNotAvailable');
  String get appointmentCancelled => translate('appointmentCancelled');
  String get queueGenerated => translate('queueGenerated');
  
  String get areYouSure => translate('areYouSure');
  String get cancelAppointmentConfirm => translate('cancelAppointmentConfirm');
  String get logoutConfirm => translate('logoutConfirm');
  
  String get today => translate('today');
  String get tomorrow => translate('tomorrow');
  String get yesterday => translate('yesterday');
  String get minutes => translate('minutes');
  String get hours => translate('hours');
  String get days => translate('days');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
