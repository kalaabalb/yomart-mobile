class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    try {
      // Safely parse the response with null checks
      final success = json['success'] as bool? ?? false;
      final message = json['message'] as String? ?? 'Unknown error';
      T? data;

      if (json['data'] != null && fromJsonT != null) {
        try {
          data = fromJsonT(json['data']);
        } catch (e) {
          data = null;
        }
      } else {
        data = null;
      }

      return ApiResponse(
        success: success,
        message: message,
        data: data,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: $e',
        data: null,
      );
    }
  }
}
