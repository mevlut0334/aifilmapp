class ApiConstants {
  ApiConstants._();

  // Base URL & Keys
  static const String baseUrl = 'https://asilov.com/api/v1';
  static const String appKey = 'ak_b0b9e8706c99317d8ca1307eda64bc01';
  static const String secretKey = 'sk_7323d36e77dae660b3d9f30a41f63f5e325165448d4ebd524f961234b44a44c7';

  // Headers
  static const String headerAppKey = 'X-App-Key';
  static const String headerSecretKey = 'X-Secret-Key';
  static const String headerAuthorization = 'Authorization';
  static const String headerAcceptLanguage = 'Accept-Language';

  // Auth Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profile = '/profile';

  // Template Endpoints
  static const String templates = '/templates';
  static String templateDetail(String uuid) => '/templates/$uuid';

  // Generation Endpoints
  static const String generationRequests = '/generation-requests';
  static String generationDetail(String uuid) => '/generation-requests/$uuid';

  // Custom Video Endpoints
  static const String customVideoRequests = '/custom-video-requests';
  static String customVideoDetail(String uuid) => '/custom-video-requests/$uuid';
  static String segmentEdit(String uuid, int segmentId) =>
      '/custom-video-requests/$uuid/segments/$segmentId/edit';
}