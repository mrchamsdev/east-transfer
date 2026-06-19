import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp {
  static String? authTokenValue;
  static int? userId;
  static String? userName;
  static String? userEmail;
  static final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  static Future<void> setAuthToken(String? token, {int? userId, String? userName, String? userEmail}) async {
    authTokenValue = token;
    final prefs = await SharedPreferences.getInstance();
    
    // Store auth token in SharedPreferences
    if (token != null && token.isNotEmpty) {
      await prefs.setString('authToken', token);
    } else {
      await prefs.remove('authToken');
    }
    
    if (userId != null) {
      MyApp.userId = userId;
      await prefs.setInt('userId', userId);
    }
    // Set static variables immediately (synchronously)
    if (userName != null) {
      MyApp.userName = userName;
      // Store in SharedPreferences asynchronously
      await prefs.setString('userName', userName);
    }
    if (userEmail != null) {
      MyApp.userEmail = userEmail;
      // Store in SharedPreferences asynchronously
      await prefs.setString('userEmail', userEmail);
    }
    
    // Emit auth state change
    _authStateController.add(isAuthenticated);
  }

  static Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    authTokenValue = prefs.getString('authToken');
    userId = prefs.getInt('userId');
    userName = prefs.getString('userName');
    userEmail = prefs.getString('userEmail');
  }

  static void clearAuthToken() async {
    authTokenValue = null;
    userId = null;
    userName = null;
    userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    
    // Emit auth state change
    _authStateController.add(false);
  }
  
  // Stream to check authentication state
  static Stream<bool> get authStateStream async* {
    // Load user data first
    await loadUserData();
    // Yield current authentication state
    yield isAuthenticated;
    // Then listen to future changes
    yield* _authStateController.stream;
  }
  
  // Future to check authentication state (for FutureBuilder)
  static Future<bool> checkAuthState() async {
    await loadUserData();
    return isAuthenticated;
  }

  static bool get isAuthenticated {
    return authTokenValue != null && authTokenValue!.isNotEmpty;
  }
}
