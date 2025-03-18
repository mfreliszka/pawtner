// lib/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'models.dart';

class UserAccountScreen extends ConsumerStatefulWidget {
  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends ConsumerState<UserAccountScreen> {
  bool _editing = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    if (user == null) {
      // If no user data is available
      return Scaffold(
        appBar: AppBar(title: Text('User Account')),
        body: Center(child: Text('No user data')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('User Account')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Hello, ${user.username}!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('User Account'),
              onTap: () {
                Navigator.pop(context);
                // Already on this screen, no action needed
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _editing
                ? TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  )
                : ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Username'),
                    subtitle: Text(user.username),
                  ),
            _editing
                ? TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  )
                : ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(user.email),
                  ),
            SizedBox(height: 20),
            if (_editing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Save profile changes
                      final newUsername = _usernameController.text.trim();
                      final newEmail = _emailController.text.trim();
                      await ref.read(authProvider.notifier).updateProfile(newUsername, newEmail);
                      // After saving, exit edit mode
                      setState(() {
                        _editing = false;
                      });
                    },
                    child: Text('Save'),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      // Cancel editing and reset fields
                      setState(() {
                        _editing = false;
                        _usernameController.text = user.username;
                        _emailController.text = user.email;
                      });
                    },
                    child: Text('Cancel'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  // Enter edit mode
                  setState(() {
                    _editing = true;
                    _usernameController.text = user.username;
                    _emailController.text = user.email;
                  });
                },
                child: Text('Edit Profile'),
              ),
          ],
        ),
      ),
    );
  }
}
