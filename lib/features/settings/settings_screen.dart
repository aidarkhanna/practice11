import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;
    final city = settings.city;
    final cities = <String>{
      ...users.map((u) => u.address.city),
      if (city != null) city,
    }.toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (v) => unawaited(settings.setDark(v)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: city,
              decoration: const InputDecoration(
                labelText: 'City filter',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (c) => unawaited(settings.setCity(c)),
            ),
          ),
        ],
      ),
    );
  }
}