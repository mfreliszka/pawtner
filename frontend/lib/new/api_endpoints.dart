//import 'package:flutter_dotenv/flutter_dotenv.dart';

//const String BASE_URL = "https://example.com/api/";
//const String BASE_URL = dotenv.env["API_BASE_URL"]!;
const String BASE_URL = "http://192.168.1.5:8000/";

// Authentication endpoints
const String REGISTER_URL = "${BASE_URL}user/register/";
const String LOGIN_URL = "${BASE_URL}user/login/";
const String REFRESH_URL = "${BASE_URL}user/token-refresh/";

// User and related data endpoints
const String USER_DETAILS_URL = "${BASE_URL}user/default/";
const String PETS_URL = "${BASE_URL}pets/";
const String FAMILY_URL = "${BASE_URL}family/";