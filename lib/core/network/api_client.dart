import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

// Thin http.Client wrapper that turns network/HTTP errors into AppExceptions.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(ApiConstants.requestTimeout);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } on FormatException {
      throw const ServerException(
          'Received a malformed response from the server.');
    } catch (_) {
      throw const NetworkException(
          'Could not reach the weather service. Check your connection.');
    }

    if (response.statusCode == 404) {
      throw const NotFoundException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(
          'Server returned status code ${response.statusCode}.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const ServerException('Unexpected response shape from server.');
    } on FormatException {
      throw const ServerException(
          'Received a malformed response from the server.');
    }
  }

  void close() => _client.close();
}
