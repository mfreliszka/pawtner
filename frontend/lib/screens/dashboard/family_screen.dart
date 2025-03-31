import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_provider.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Family Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
