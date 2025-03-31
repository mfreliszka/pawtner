import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                SizedBox(height: 20),
                Text(
                  'Username', // Replace with actual username
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
