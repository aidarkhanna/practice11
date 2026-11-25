import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  final _storage = const FlutterSecureStorage();
  static const _key = 'token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _key);
    } on PlatformException {
      // Keystore keys can be lost (for example the lock screen was removed):
      // treat it as "signed out", not as a crash.
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _key);
}
