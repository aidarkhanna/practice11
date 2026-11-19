import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, this.host = 'jsonplaceholder.typicode.com'})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => {'Accept': 'application/json'};

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.https(host, path, query);
    final response = await _send(() => _client.get(uri, headers: _headers));
    _check(response);
    return response;
  }

  Future<http.Response> post(String path, Object body) async {
    final uri = Uri.https(host, path);
    final response = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(response);
    return response;
  }

  dynamic decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${response.request?.method} ${response.request?.url} '
          '-> ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    final code = r.statusCode;
    if (code == 401) throw const UnauthorizedException();
    if (code == 404) throw const NotFoundException();
    if (code >= 500) throw ServerException(code);
    if (code >= 400) throw BadResponseException('HTTP $code');
  }
}
