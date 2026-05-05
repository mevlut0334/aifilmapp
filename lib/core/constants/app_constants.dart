class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Asilov';

  // Supported Locales
  static const String localeEn = 'en';
  static const String localeTr = 'tr';
  static const List<String> supportedLocales = [localeEn, localeTr];
  static const String defaultLocale = localeEn;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String localeKey = 'app_locale';

  // Pagination
  static const int defaultPageSize = 20;

  // Polling
  static const int pollingIntervalSeconds = 5;

  // Image Upload
  static const int maxImageSizeMB = 10;

  // Timeouts
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;

  // Generation Types
  static const String typeTemplateImage = 'template_image';
  static const String typeTemplateVideo = 'template_video';
  static const String typeCustomImage = 'custom_image';

  // Video Formats
  static const String formatVertical = 'vertical';
  static const String formatHorizontal = 'horizontal';
  static const String formatSquare = 'square';

  // Orientation
  static const String orientationLandscape = 'landscape';
  static const String orientationPortrait = 'portrait';
  static const String orientationSquare = 'square';

  // Job Types
  static const String jobTypeTemplateGeneration = 'template_generation';
  static const String jobTypeCustomImage = 'custom_image';
  static const String jobTypeCustomVideo = 'custom_video';
  static const String jobTypeSegmentEdit = 'segment_edit';

  // Segment Status
  static const String statusPending = 'pending';
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
}