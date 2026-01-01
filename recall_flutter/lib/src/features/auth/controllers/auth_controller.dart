import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recall_client/recall_client.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import '../../../../core/ip_config.dart';
import '../../../../main.dart';

/// Stores the currently signed-in Google user
GoogleSignInAccount? currentGoogleUser;

/// Key for storing login state
const String _isLoggedInKey = 'is_logged_in';
const String _userNameKey = 'user_name';
const String _userEmailKey = 'user_email';
const String _userPhotoKey = 'user_photo';

class AuthController {
  final Ref ref;

  AuthController(this.ref);

  /// Check if user is already logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get stored user info
  static Future<Map<String, String?>> getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'photo': prefs.getString(_userPhotoKey),
    };
  }

  /// Try to restore session silently
  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) return false;

      final googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/gmail.readonly',
        ],
        serverClientId: '59154691355-q448tcg88mp3pg4pgsfhev4eje8q6nup.apps.googleusercontent.com',
      );

      // Try silent sign-in
      final googleUser = await googleSignIn.signInSilently();
      
      if (googleUser != null) {
        currentGoogleUser = googleUser;
        print('Auto-login successful: ${googleUser.email}');
        return true;
      }
      
      // If silent sign-in fails but we have stored info, still consider logged in
      final storedName = prefs.getString(_userNameKey);
      if (storedName != null && storedName.isNotEmpty) {
        print('Using stored user info for: $storedName');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Auto-login error: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('=== Starting Google Sign-In ===');
      
      // Request Gmail API scope for offline access
      final googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/gmail.readonly',
        ],
        serverClientId: '59154691355-q448tcg88mp3pg4pgsfhev4eje8q6nup.apps.googleusercontent.com',
        forceCodeForRefreshToken: true, // CRITICAL: Always get fresh code for refresh token
      );

      // IMPORTANT: Sign out first to ensure we get a FRESH serverAuthCode
      // Cached sessions from signInSilently() may have already-consumed codes
      print('Signing out to force fresh auth code...');
      await googleSignIn.signOut();

      print('Requesting fresh sign-in with Gmail scope...');
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Sign-in cancelled by user or failed');
        return false;
      }

      // Store the Google user globally
      currentGoogleUser = googleUser;

      // Save login state to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userNameKey, googleUser.displayName ?? '');
      await prefs.setString(_userEmailKey, googleUser.email);
      if (googleUser.photoUrl != null) {
        await prefs.setString(_userPhotoKey, googleUser.photoUrl!);
      }

      print('✓ Google user signed in successfully!');
      print('  Email: ${googleUser.email}');
      print('  Name: ${googleUser.displayName}');
      print('  Photo: ${googleUser.photoUrl}');

      // Get tokens
      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      final authCode = googleUser.serverAuthCode;

      print('Server auth code: ${authCode != null ? "received" : "null"}');
      print('ID Token: ${idToken != null ? "received" : "null"}');
      
      if (idToken == null) {
        print('Error: Missing ID Token');
        return false;
      }

      // Authenticate with Serverpod using ID Token
      try {
        print('Authenticating with Serverpod (ID Token)...');
        // 'google' module usually exposes authenticateWithIdToken
        // Check if the generated client matches this signature.
        // Standard Serverpod Auth Google uses 'authenticateWithIdToken'
        final serverAuth = await client.modules.auth.google.authenticateWithIdToken(
          idToken,
        );
        
        if (serverAuth.success) {
          print('✓ Serverpod authentication successful!');
          await sessionManager.registerSignedInUser(
            serverAuth.userInfo!,
            serverAuth.keyId!,
            serverAuth.key!,
          );
          
          // Exchange Auth Code for Refresh Token (if available)
          if (authCode != null) {
            print('Exchanging auth code for Gmail refresh token...');
            try {
              final userId = serverAuth.userInfo!.id!;
              // Use a temporary client WITHOUT auth headers to avoid JWT validation issues
              // The server's JWT validation rejects legacy auth tokens
              final tempClient = Client(
                'http://$serverIpAddress:8080/',
                // No authenticationKeyManager = no auth headers sent
              );
              final success = await tempClient.dashboard.exchangeAndStoreGmailToken(authCode, userId);
              tempClient.close();
              if (success) {
                 print('✓ Gmail refresh token stored');
              } else {
                 print('Warning: Failed to store Gmail refresh token');
              }
            } catch (e) {
              print('Gmail token exchange error: $e');
            }
          }
        } else {
           print('Serverpod authentication failed: ${serverAuth.failReason ?? "Unknown"}');
           return false;
        }
      } catch (e) {
        print('Serverpod auth error: $e');
        return false;
      }
      
      return true;
      
    } catch (e, stack) {
      print('Sign in error: $e');
      print('Stack: $stack');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    currentGoogleUser = null;
    
    // Clear stored login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhotoKey);
    
    try {
      await sessionManager.signOutDevice();
    } catch (e) {
      print('Session signout error: $e');
    }
  }
}

final authControllerProvider = Provider((ref) => AuthController(ref));

/// Provider to store user info from SharedPreferences
class StoredUserInfo {
  final String? name;
  final String? email;
  final String? photo;
  
  StoredUserInfo({this.name, this.email, this.photo});
}

StoredUserInfo? storedUserInfo;

Future<void> loadStoredUserInfo() async {
  final info = await AuthController.getStoredUserInfo();
  storedUserInfo = StoredUserInfo(
    name: info['name'],
    email: info['email'],
    photo: info['photo'],
  );
}
