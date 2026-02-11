// App Constants
class AppConstants {
  // API Configuration
  // API Configuration
  // Official Backend API: http://10.161.94.61:5000/api
  // static const String baseUrl = 'http://10.161.94.61:5000/api'; 
  static const String baseUrl = 'http://localhost:5000/api';

  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';
  
  // Polling Intervals
  static const Duration queuePollingInterval = Duration(seconds: 5);
  static const Duration notificationPollingInterval = Duration(seconds: 10);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Service Modes
  static const String serviceModeOnline = 'ONLINE';
  static const String serviceModeQueue = 'QUEUE';
  static const String serviceModeAppointment = 'APPOINTMENT';
  
  // Request Status
  static const String statusCompleted = 'COMPLETED';
  static const String statusInProgress = 'IN_PROGRESS';
  static const String statusRejected = 'REJECTED';
  
  // Queue Status
  static const String queueStatusWaiting = 'WAITING';
  static const String queueStatusCalled = 'CALLED';
  static const String queueStatusInService = 'IN_SERVICE';
  static const String queueStatusCompleted = 'COMPLETED';
  static const String queueStatusCancelled = 'CANCELLED';
  static const String queueStatusNoShow = 'NO_SHOW';
  
  // Appointment Status
  static const String appointmentStatusConfirmed = 'CONFIRMED';
  static const String appointmentStatusCancelled = 'CANCELLED';
  static const String appointmentStatusCompleted = 'COMPLETED';
  static const String appointmentStatusNoShow = 'NO_SHOW';
  
  // Notification Types
  static const String notifTypeQueueIssued = 'QUEUE_ISSUED';
  static const String notifTypeQueueCalled = 'QUEUE_CALLED';
  static const String notifTypeAppointmentConfirmed = 'APPOINTMENT_CONFIRMED';
  static const String notifTypeAppointmentReminder = 'APPOINTMENT_REMINDER';
  static const String notifTypeStatusChanged = 'STATUS_CHANGED';
  
  // User Roles
  static const String roleCitizen = 'CITIZEN';
  static const String roleHelpDesk = 'HELP_DESK';
  static const String roleServiceOfficer = 'SERVICE_OFFICER';
  static const String roleAdmin = 'ADMIN';
  
  // Languages
  static const String languageEnglish = 'en';
  static const String languageAmharic = 'am';
}
