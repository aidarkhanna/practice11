import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<UsersModel>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            isThreeLine: true,
            title: Text(u.name),
            subtitle: Text('${u.email}\n${u.address.city}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => UserDetailScreen(u)),
            ),
          );
        },
      ),
    );
  }
}
