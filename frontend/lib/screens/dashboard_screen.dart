import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_provider.dart';
import 'dashboard/settings_screen.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/pets_screen.dart';
import 'dashboard/family_screen.dart';
import 'dashboard/profile_screen.dart';

// Provider to manage bottom navigation state
final bottomNavProvider = StateNotifierProvider<BottomNavNotifier, int>((ref) {
  return BottomNavNotifier();
});

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void changeIndex(int index) {
    state = index;
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // List of screens to navigate between
  final List<Widget> _screens = [
    const HomeScreen(),
    const PetsScreen(),
    const FamilyScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get the current selected index from the provider
    final currentIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Update the selected index using the provider
          ref.read(bottomNavProvider.notifier).changeIndex(index);
        },
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom_outlined),
            activeIcon: Icon(Icons.family_restroom),
            label: 'Family',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
