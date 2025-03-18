// lib/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Attempt auto login if tokens are stored
    Future.microtask(() async {
      bool success = await ref.read(authProvider.notifier).tryAutoLogin();
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              // Display error if login failed
              if (authState.error != null)
                Text(authState.error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: authState.isLoading ? null : () async {
                  await ref.read(authProvider.notifier).login(
                        _usernameController.text.trim(),
                        _passwordController.text,
                      );
                  // Navigate if login was successful
                  if (ref.read(authProvider).isAuthenticated) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                child: authState.isLoading 
                    ? SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Login'),
              ),
              TextButton(
                onPressed: authState.isLoading ? null : () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
