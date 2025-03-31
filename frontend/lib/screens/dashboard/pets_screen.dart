import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_provider.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Pets Screen', style: TextStyle(fontSize: 24))),
    );
  }
}
