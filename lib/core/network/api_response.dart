class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? locale;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.locale,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      locale: json['locale'] as String?,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
}