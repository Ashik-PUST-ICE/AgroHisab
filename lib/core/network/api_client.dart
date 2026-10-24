import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });
}

class ApiClient {
  final TokenStorage _storage = TokenStorage();
  final String _baseUrl = Platform.isAndroid || Platform.isIOS
      ? ApiEndpoints.defaultBaseUrl
      : 'http://localhost:8000/api';

  Uri _uri(String endpoint) => Uri.parse('$_baseUrl${ApiEndpoints.servicePrefixFor(endpoint)}$endpoint');

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponse<dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = _uri(endpoint);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: await _headers());
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'সার্ভারে সংযোগ দেওয়া সম্ভব হয়নি: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = _uri(endpoint);
      final response = await http.post(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'সার্ভারে সংযোগ দেওয়া সম্ভব হয়নি: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = _uri(endpoint);
      final response = await http.put(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'সার্ভারে সংযোগ দেওয়া সম্ভব হয়নি: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> delete(String endpoint) async {
    try {
      final uri = _uri(endpoint);
      final response = await http.delete(uri, headers: await _headers());
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'সার্ভারে সংযোগ দেওয়া সম্ভব হয়নি: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> uploadMultipart(
    String endpoint, {
    required File file,
    String fileField = 'file',
    Map<String, String>? fields,
  }) async {
    try {
      final uri = _uri(endpoint);
      final request = http.MultipartRequest('POST', uri);
      final token = await _storage.getToken();
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'ফাইল আপলোড ব্যর্থ হয়েছে: ${e.toString()}');
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final success = decoded['success'] ?? (response.statusCode >= 200 && response.statusCode < 300);
        final message = decoded['message'] ?? (success ? 'সফল হয়েছে' : 'অনুরোধ ব্যর্থ হয়েছে');
        final data = decoded['data'] ?? decoded;
        final errors = decoded['errors'] is Map<String, dynamic> ? decoded['errors'] as Map<String, dynamic> : null;

        return ApiResponse(
          success: success,
          message: message,
          data: data,
          errors: errors,
        );
      }
      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: 'অনুরোধ সম্পন্ন হয়েছে',
        data: decoded,
      );
    } catch (_) {
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      return ApiResponse(
        success: isSuccess,
        message: isSuccess ? 'সফল হয়েছে' : 'সার্ভার ত্রুটি: ${response.statusCode}',
        data: response.body,
      );
    }
  }
}
