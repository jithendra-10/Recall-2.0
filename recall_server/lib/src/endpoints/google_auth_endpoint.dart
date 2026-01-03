import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';

class GoogleAuthEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<bool> exchangeCode(Session session, String authCode) async {
    final authenticationInfo = session.authenticated;
    if (authenticationInfo == null) return false;

    final userId = int.tryParse(authenticationInfo.userIdentifier);
    if (userId == null) return false;

    // TODO: Move to config
    const clientId = 'YOUR_CLIENT_ID';
    const clientSecret = 'YOUR_CLIENT_SECRET';
    // For mobile, redirectUri is often specific or null.
    // If using 'serverAuthCode' from google_sign_in, redirect_uri might need to be empty or matched.
    const redirectUri = '';

    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'code': authCode,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode != 200) {
      session.log(
        'Failed to exchange code: ${response.body}',
        level: LogLevel.error,
      );
      return false;
    }

    final data = jsonDecode(response.body);
    final refreshToken = data['refresh_token'];

    if (refreshToken == null) {
      session.log('No refresh token returned', level: LogLevel.warning);
      return false;
    }

    // Store in UserConfig
    var userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (userConfig != null) {
      userConfig.googleRefreshToken = refreshToken;
      await UserConfig.db.updateRow(session, userConfig);
    } else {
      userConfig = UserConfig(
        userInfoId: userId,
        googleRefreshToken: refreshToken,
      );
      await UserConfig.db.insertRow(session, userConfig);
    }

    return true;
  }
}
