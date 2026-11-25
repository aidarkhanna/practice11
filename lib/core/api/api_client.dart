import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._store, {
    http.Client? client,
    this.host = 'jsonplaceholder.typicode.com',
  }) : _client = client ?? http.Client();

  final SecureStore _store;
  final http.Client _client;
  final String host;

  // The header is built here: the repository never sees the token.
  Future<Map<String, String>> _headers() async => {
        'Accept': 'application/json',
        if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
      };

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.https(host, path, query);
    final headers = await _headers();
    final response = await _send(() => _client.get(uri, headers: headers));
    _check(response);
    return response;
  }

  Future<http.Response> post(String path, Object body) async {
    final uri = Uri.https(host, path);
    final headers = await _headers();
    final response = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
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