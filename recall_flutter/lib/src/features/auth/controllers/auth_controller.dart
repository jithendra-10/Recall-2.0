import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recall_client/recall_client.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import '../../../../core/ip_config.dart';
import '../../../../main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// interactive configuration - Forces fresh Auth Code for backend refresh token
  GoogleSignIn get _googleSignInInteractive => GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.compose',
    ],
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
    forceCodeForRefreshToken: true,
  );

  /// Silent configuration - Only needs ID Token for authentication, no new code needed
  GoogleSignIn get _googleSignInSilent => GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.compose',
    ],
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
    forceCodeForRefreshToken: false, // CRITICAL: Disable for silent sign-in to work reliable
  );

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
      print('tryAutoLogin: Initializing session manager...');
      // 1. Ensure SessionManager is initialized (loads key from storage)
      await sessionManager.initialize();
      print('tryAutoLogin: Session initialized. Is Signed In? ${sessionManager.isSignedIn}');

      // 2. Check if Serverpod considers us signed in
      if (sessionManager.isSignedIn) {
        print('Auto-login successful: User ${sessionManager.signedInUser?.id}');
        
        // Restore Google User (Silently) to keep client-side tokens fresh
        try {
          currentGoogleUser = await _googleSignInSilent.signInSilently();
        } catch (e) {
          print('Silent Google Sign-In refresh failed (non-fatal): $e');
        }

        return true;
      } 
      
      // 3. If SessionManager is missing, attempt RECOVERY mechanism
      print('tryAutoLogin: SessionManager missing. Attempting silent recovery via Google...');
      
      try {
        // Attempt silent Google Sign-In to recover session
        // Use SILENT config (no forced code)
        final googleUser = await _googleSignInSilent.signInSilently();
        
        if (googleUser != null) {
           print('tryAutoLogin: Silent Google success. Re-authenticating with Serverpod...');
           currentGoogleUser = googleUser;
           
           final auth = await googleUser.authentication;
           final idToken = auth.idToken;
           
           if (idToken != null) {
             final serverAuth = await client.modules.auth.google.authenticateWithIdToken(idToken);
             if (serverAuth.success) {
               print('tryAutoLogin: RECOVERY SUCCESS! Session restored.');
               await sessionManager.registerSignedInUser(
                  serverAuth.userInfo!,
                  serverAuth.keyId!,
                  serverAuth.key!,
               );
               
               // Persist local state again just in case
               final prefs = await SharedPreferences.getInstance();
               await prefs.setBool(_isLoggedInKey, true);
               await prefs.setString(_userNameKey, googleUser.displayName ?? '');
               
               return true;
             } else {
                print('tryAutoLogin: Serverpod auth failed during recovery: ${serverAuth.failReason}');
             }
           } else {
              print('tryAutoLogin: No ID Token from silent sign in');
           }
        } else {
           print('tryAutoLogin: Google silent sign-in returned null (user likely revoked access or needs login)');
        }
      } catch (e) {
        print('tryAutoLogin: Silent recovery error: $e');
      }
      
      // 4. If all fails, we are NOT logged in. Clear state.
      print('tryAutoLogin: Auto-login failed completely. Clearing prefs.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      
      return false;
    } catch (e) {
      print('Auto-login critical error: $e');
      return false;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      print('=== Starting Google Sign-In ===');
      // Use INTERACTIVE config for explicit sign in
      final googleSignIn = _googleSignInInteractive;

      // IMPORTANT: Sign out first to ensure we get a FRESH serverAuthCode
      print('Signing out to force fresh auth code...');
      await googleSignIn.signOut();

      print('Requesting fresh sign-in with Gmail scope...');
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return 'Sign in cancelled by user';
      }

      currentGoogleUser = googleUser;
      print('✓ Google user signed in: ${googleUser.email}');

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      final authCode = googleUser.serverAuthCode;

      print('Server auth code: ${authCode != null ? "received" : "null"}');
      
      if (idToken == null) {
        await signOut();
        return 'Failed to retrieve ID Token from Google';
      }

      // Authenticate with Serverpod using ID Token
      try {
        print('Authenticating with Serverpod (ID Token)...');
        final serverAuth = await client.modules.auth.google.authenticateWithIdToken(idToken);
        
        if (serverAuth.success) {
          print('✓ Serverpod authentication successful!');
          await sessionManager.registerSignedInUser(
            serverAuth.userInfo!,
            serverAuth.keyId!,
            serverAuth.key!,
          );
          
          if (authCode != null) {
            print('Exchanging auth code for Gmail refresh token...');
            try {
              final userId = serverAuth.userInfo!.id!;
              // Using main client which is now authenticated
              final success = await client.dashboard.exchangeAndStoreGmailToken(authCode, userId);

              if (!success) {
                 await signOut();
                 return 'Failed to store Gmail access. Please try again.';
              }
            } catch (e) {
              print('Gmail token exchange error: $e');
              await signOut();
              return 'Server connection failed during token exchange: $e';
            }
          }
        } else {
           print('Serverpod authentication failed: ${serverAuth.failReason}');
           await signOut();
           return 'Backend authentication failed: ${serverAuth.failReason}';
        }
      } catch (e) {
        print('Serverpod auth error: $e');
        await signOut();
        return 'Server connection failed: $e';
      }
      
      // === SUCCESS: ONLY NOW SAVE STATE ===
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userNameKey, googleUser.displayName ?? '');
      await prefs.setString(_userEmailKey, googleUser.email);
      if (googleUser.photoUrl != null) {
        await prefs.setString(_userPhotoKey, googleUser.photoUrl!);
      }

      print('✓ Login Complete & Persisted');
      return null; // Success
      
    } catch (e, stack) {
      print('Sign in error: $e');
      await signOut();
      return 'Unexpected error: $e';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Sign out of both configs just to be safe
    try { await _googleSignInSilent.signOut(); } catch (_) {}
    try { await _googleSignInInteractive.signOut(); } catch (_) {}
    
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
