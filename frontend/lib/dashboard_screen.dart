// lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'models.dart';

class UserDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final pets = authState.pets;
    final families = authState.families;

    return Scaffold(
      appBar: AppBar(title: Text('User Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                user != null ? 'Hello, ${user.username}!' : 'Hello!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('User Account'),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pushNamed(context, '/account');
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Pets Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Pets', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Show dialog to add a new pet
                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     String newPetName = '';
                      //     return AlertDialog(
                      //       title: Text('Add Pet'),
                      //       content: TextField(
                      //         decoration: InputDecoration(labelText: 'Pet Name'),
                      //         onChanged: (val) {
                      //           newPetName = val;
                      //         },
                      //       ),
                      //       actions: [
                      //         TextButton(
                      //           onPressed: () => Navigator.of(context).pop(),
                      //           child: Text('Cancel'),
                      //         ),
                      //         TextButton(
                      //           onPressed: () {
                      //             if (newPetName.trim().isNotEmpty) {
                      //               ref.read(authProvider.notifier).addPet(newPetName.trim());
                      //             }
                      //             Navigator.of(context).pop();
                      //           },
                      //           child: Text('Add'),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // );
                      showDialog(
                        context: context,
                        builder: (context) {
                          String newPetName = '';
                          String selectedSpecies = 'DOG'; // default
                          return AlertDialog(
                            title: Text('Add Pet'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(labelText: 'Pet Name'),
                                  onChanged: (val) => newPetName = val,
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: 'Species'),
                                  value: selectedSpecies,
                                  items: [
                                    DropdownMenuItem(value: 'DOG', child: Text('Dog')),
                                    DropdownMenuItem(value: 'CAT', child: Text('Cat')),
                                  ],
                                  onChanged: (val) => selectedSpecies = val!,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (newPetName.trim().isNotEmpty) {
                                    ref.read(authProvider.notifier).addPet(newPetName.trim(), selectedSpecies);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text('Add'),
                              ),
                            ],
                          );
                        },
                      );

                    },
                  ),
                ],
              ),
              if (pets.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No pets yet.'),
                ),
              ...pets.map((pet) => ListTile(
                    title: Text(pet.name),
                    subtitle: Text('ID: ${pet.id}'),
                  )),
              SizedBox(height: 20),
              // Family Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Family', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          String newFamilyName = '';
                          return AlertDialog(
                            title: Text('Add Family'),
                            content: TextField(
                              decoration: InputDecoration(labelText: 'Family Name'),
                              onChanged: (val) {
                                newFamilyName = val;
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (newFamilyName.trim().isNotEmpty) {
                                    ref.read(authProvider.notifier).addFamily(newFamilyName.trim());
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              if (families.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No family groups yet.'),
                ),
              ...families.map((family) => ListTile(
                    title: Text(family.name),
                    subtitle: Text('ID: ${family.id}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
