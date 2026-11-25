import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user.username),
            subtitle: const Text('Username'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(user.website ?? 'No website'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text('${a.city}, ${a.zipcode}'),
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: Text('${a.geo.lat}, ${a.geo.lng}'),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy token to clipboard'),
                onPressed: () async {
                  final token = await context.read<SecureStore>().readToken();
                  if (token == null) return;
                  await Clipboard.setData(ClipboardData(text: token));
                },
              ),
            ),
        ],
      ),
    );
  }
}