import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

Future<void> _open(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No app can open this')),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final site = user.website;

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
            onTap: () => _open(
              context,
              Uri(scheme: 'mailto', path: user.email),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () => _open(
              context,
              Uri(scheme: 'tel', path: user.phoneDigits),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(site ?? 'No website'),
            onTap: site == null
                ? null
                : () => _open(context, Uri.parse('https://$site')),
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