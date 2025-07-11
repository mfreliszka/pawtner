class UserModel {
  final String username;
  final String email;
  final List<String> ownedPets; // list of pet UUIDs
  final List<String> memberOfFamilies; // list of family UUIDs

  UserModel({
    required this.username,
    required this.email,
    required this.ownedPets,
    required this.memberOfFamilies,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'] ?? '',
      ownedPets: List<String>.from(json['owned_pets'] ?? []),
      memberOfFamilies: List<String>.from(json['member_of_families'] ?? []),
    );
  }

  // Helpers to update owned pets or families list
  UserModel copyWithNewPet(String petId) {
    final updatedPets = List<String>.from(ownedPets)..add(petId);
    return UserModel(
      username: username,
      email: email,
      ownedPets: updatedPets,
      memberOfFamilies: memberOfFamilies,
    );
  }

  UserModel copyWithNewFamily(String familyId) {
    final updatedFamilies = List<String>.from(memberOfFamilies)..add(familyId);
    return UserModel(
      username: username,
      email: email,
      ownedPets: ownedPets,
      memberOfFamilies: updatedFamilies,
    );
  }
}

// class PetModel {
//   final String id;
//   final String name;
//   // Add other pet fields if needed

//   PetModel({required this.id, required this.name});

//   factory PetModel.fromJson(Map<String, dynamic> json) {
//     return PetModel(
//       id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
//       name: json['name'] ?? '',
//     );
//   }
// }
class PetModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? breed;
  final int? age;
  // Add other pet fields if needed

  PetModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.breed,
    this.age,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      breed: json['breed'],
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
    );
  }
}

class FamilyModel {
  final String id;
  final String name;
  // Add other family fields if needed

  FamilyModel({required this.id, required this.name});

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}
