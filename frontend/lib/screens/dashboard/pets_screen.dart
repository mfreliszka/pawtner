import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_provider.dart';

import 'package:frontend/models.dart';
import '../../api_endpoints.dart';
import '../../auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final petsProvider = Provider<List<PetModel>>((ref) {
  final authState = ref.watch(authProvider);
  return authState.pets;
});

class PetsScreen extends ConsumerWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final pets = ref.watch(petsProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    return Scaffold(
      appBar: AppBar(title: const Text('My Pets'), elevation: 2),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load pets',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Try refreshing user data
                          final authNotifier = ref.read(authProvider.notifier);
                          authNotifier.tryAutoLogin();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
              : pets.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No pets added yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first pet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetCard(pet: pet);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddPetScreen()));

          // If returned with a successful result, refresh pets
          if (result == true) {
            // We don't need to manually refresh since auth state should be updated
            // But we could call authNotifier.tryAutoLogin() here if needed
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final PetModel pet;

  const PetCard({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PetDetailsScreen(petId: pet.id),
            ),
          );
        },
        child: Row(
          children: [
            // Pet image
            SizedBox(
              width: 120,
              height: 120,
              child:
                  pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                      ? Image.network(
                        pet.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
            ),
            // Pet details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (pet.breed != null && pet.breed!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          pet.breed!,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    if (pet.age != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${pet.age} years old',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Arrow icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for AddPetScreen
class AddPetScreen extends StatelessWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      body: const Center(child: Text('Add Pet Screen')),
    );
  }
}

// Placeholder for PetDetailsScreen
class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Details')),
      body: Center(child: Text('Pet Details for ID: $petId')),
    );
  }
}

// class PetsScreen extends StatelessWidget {
//   const PetsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: Text('Pets Screen', style: TextStyle(fontSize: 24))),
//     );
//   }
// }
