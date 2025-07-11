import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'api_endpoints.dart';

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final List<PetModel> pets;
  final List<FamilyModel> families;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.user,
    required this.pets,
    required this.families,
    required this.isLoading,
    this.error,
  });

  // Initial (logged out) state
  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      user: null,
      pets: [],
      families: [],
      isLoading: false,
      error: null,
    );
  }

  // Convenient method to create a modified copy
  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    List<PetModel>? pets,
    List<FamilyModel>? families,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      pets: pets ?? this.pets,
      families: families ?? this.families,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  AuthNotifier() : super(AuthState.initial());

  // Attempt automatic login using stored tokens
  Future<bool> tryAutoLogin() async {
    final storedAccess = await _secureStorage.read(key: 'accessToken');
    final storedRefresh = await _secureStorage.read(key: 'refreshToken');
    if (storedAccess == null || storedRefresh == null) {
      return false;
    }
    _accessToken = storedAccess;
    _refreshToken = storedRefresh;
    // Try to fetch user details with existing access token
    final response = await http.get(
      Uri.parse(USER_DETAILS_URL),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      final user = UserModel.fromJson(userData);
      // Fetch pets and families details
      final petsList = await _fetchAllPets(user.ownedPets);
      final familiesList = await _fetchAllFamilies(user.memberOfFamilies);
      state = AuthState(
        isAuthenticated: true,
        user: user,
        pets: petsList,
        families: familiesList,
        isLoading: false,
        error: null,
      );
      return true;
    } else if (response.statusCode == 401) {
      // Access token expired, try to refresh
      final refreshed = await _refreshAccessToken();
      if (!refreshed) return false;
      // Retry fetching user details with new access token
      final response2 = await http.get(
        Uri.parse(USER_DETAILS_URL),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (response2.statusCode == 200) {
        final userData = json.decode(response2.body);
        final user = UserModel.fromJson(userData);
        final petsList = await _fetchAllPets(user.ownedPets);
        final familiesList = await _fetchAllFamilies(user.memberOfFamilies);
        state = AuthState(
          isAuthenticated: true,
          user: user,
          pets: petsList,
          families: familiesList,
          isLoading: false,
          error: null,
        );
        return true;
      }
    }
    return false;
  }

  // Login user and fetch profile data
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await http.post(
      Uri.parse(LOGIN_URL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assume the response contains an access and refresh token
      _accessToken =
          data['access'] ??
          data['token']; // 'token' if API returns it under a different key
      _refreshToken = data['refresh'];
      // Save tokens securely
      await _secureStorage.write(key: 'accessToken', value: _accessToken);
      await _secureStorage.write(key: 'refreshToken', value: _refreshToken);
      // Fetch user details and related data
      final userSuccess = await _fetchUserAndRelated();
      if (!userSuccess) {
        state = AuthState.initial().copyWith(
          error: 'Failed to fetch user data',
        );
      }
    } else if (response.statusCode == 401) {
      throw Exception('401 Unauthorized');
    } else {
      state = AuthState.initial().copyWith(error: 'Login failed');
    }
  }

  // Register a new user, then log them in
  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await http.post(
      Uri.parse(REGISTER_URL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Registration successful, now log in with the new credentials
      await login(username, password);
    } else if (response.statusCode == 400) {
      throw Exception(response.body);
    } else {
      state = AuthState.initial().copyWith(error: 'Registration failed');
    }
  }

  // Refresh the access token using the refresh token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    final response = await http.post(
      Uri.parse(REFRESH_URL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access'] ?? data['token'];
      // Update refresh token if provided (rotating refresh tokens)
      if (data['refresh'] != null) {
        _refreshToken = data['refresh'];
        await _secureStorage.write(key: 'refreshToken', value: _refreshToken);
      }
      // Save new access token
      await _secureStorage.write(key: 'accessToken', value: _accessToken);
      return true;
    } else {
      return false;
    }
  }

  // Fetch user profile and related pet/family data
  Future<bool> _fetchUserAndRelated() async {
    if (_accessToken == null) return false;
    final res = await http.get(
      Uri.parse(USER_DETAILS_URL),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (res.statusCode == 200) {
      final userData = json.decode(res.body);
      final user = UserModel.fromJson(userData);
      final petsList = await _fetchAllPets(user.ownedPets);
      final familiesList = await _fetchAllFamilies(user.memberOfFamilies);
      state = AuthState(
        isAuthenticated: true,
        user: user,
        pets: petsList,
        families: familiesList,
        isLoading: false,
        error: null,
      );
      return true;
    } else if (res.statusCode == 401) {
      // If unauthorized, try refresh and then retry once
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return await _fetchUserAndRelated();
      }
      state = AuthState.initial().copyWith(
        error: 'Session expired, please log in again',
      );
      return false;
    }
    return false;
  }

  // Helper to fetch all pet details by their IDs
  Future<List<PetModel>> _fetchAllPets(List<String> petIds) async {
    List<PetModel> petsList = [];
    for (String petId in petIds) {
      final res = await http.get(
        Uri.parse("$PETS_URL$petId"),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (res.statusCode == 200) {
        final petData = json.decode(res.body);
        petsList.add(PetModel.fromJson(petData));
      }
      // If a pet fetch fails, we skip it for brevity
    }
    return petsList;
  }

  // Helper to fetch all family details by their IDs
  Future<List<FamilyModel>> _fetchAllFamilies(List<String> familyIds) async {
    List<FamilyModel> familiesList = [];
    for (String familyId in familyIds) {
      final res = await http.get(
        Uri.parse("$FAMILY_URL$familyId"),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (res.statusCode == 200) {
        final familyData = json.decode(res.body);
        familiesList.add(FamilyModel.fromJson(familyData));
      }
    }
    return familiesList;
  }

  // Add a new pet (POST to pets endpoint)
  Future<void> addPet(String name, String species) async {
    if (_accessToken == null) return;
    final res = await http.post(
      Uri.parse(PETS_URL),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'species': species,
        'description': '',
        'breed': '',
        'family': null,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final petData = json.decode(res.body);
      final newPet = PetModel.fromJson(petData);
      // Update state with the new pet
      final updatedPets = List<PetModel>.from(state.pets)..add(newPet);
      final updatedUser =
          state.user != null
              ? state.user!.copyWithNewPet(newPet.id)
              : state.user;
      state = state.copyWith(pets: updatedPets, user: updatedUser);
    } else if (res.statusCode == 401) {
      // Unauthorized: try refreshing token and retry once
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        await addPet(name, species);
      }
    }
  }

  // Add a new family (POST to family endpoint)
  Future<void> addFamily(String name) async {
    if (_accessToken == null) return;
    final res = await http.post(
      Uri.parse(FAMILY_URL),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final familyData = json.decode(res.body);
      final newFamily = FamilyModel.fromJson(familyData);
      final updatedFamilies = List<FamilyModel>.from(state.families)
        ..add(newFamily);
      final updatedUser =
          state.user != null
              ? state.user!.copyWithNewFamily(newFamily.id)
              : state.user;
      state = state.copyWith(families: updatedFamilies, user: updatedUser);
    } else if (res.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        await addFamily(name);
      }
    }
  }

  // Logout the user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    _accessToken = null;
    _refreshToken = null;
    state = AuthState.initial();
  }

  // Update profile (username/email) - assuming the API allows PUT on user/default/
  Future<void> updateProfile(String newUsername, String newEmail) async {
    if (_accessToken == null || state.user == null) return;
    final res = await http.put(
      Uri.parse(USER_DETAILS_URL),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': newUsername, 'email': newEmail}),
    );
    if (res.statusCode == 200) {
      final userData = json.decode(res.body);
      final updatedUser = UserModel.fromJson(userData);
      state = state.copyWith(user: updatedUser);
    } else if (res.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        await updateProfile(newUsername, newEmail);
      }
    }
  }
}

// Riverpod provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
