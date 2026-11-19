import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final http.Response response = await _api.get('/users');
    final json = _api.decode(response);
    try {
      return [
        for (final item in json as List<dynamic>)
          User.fromJson(item as Map<String, dynamic>),
      ];
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<User> getById(int id) async {
    final http.Response response = await _api.get('/users/$id');
    final json = _api.decode(response);
    try {
      return User.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final http.Response response = await _api.post('/users', draft.toJson());
    if (response.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${response.statusCode}',
      );
    }
    final json = _api.decode(response);
    try {
      return User.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('POST users: $e');
    }
  }
}
