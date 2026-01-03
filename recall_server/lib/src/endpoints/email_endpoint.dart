import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';

class EmailEndpoint extends Endpoint {
  // Load credentials from config file (reusing logic from sync)
  static late String _clientId;
  static late String _clientSecret;
  static bool _credentialsLoaded = false;

  static Future<void> _loadCredentials() async {
    if (_credentialsLoaded) return;
    
    try {
      final configFile = File('config/google_client_secret.json');
      final configJson = jsonDecode(await configFile.readAsString());
      _clientId = configJson['web']['client_id'];
      _clientSecret = configJson['web']['client_secret'];
      _credentialsLoaded = true;
    } catch (e) {
      throw Exception('Failed to load Google credentials: $e');
    }
  }

  Future<bool> sendEmail(Session session, String to, String subject, String body) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) {
      throw Exception('User not authenticated');
    }
    final userId = int.parse(userIdentifier);

    await _loadCredentials();

    final userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (userConfig == null || userConfig.googleRefreshToken == null) {
      throw Exception('User has not connected Gmail');
    }

    final refreshToken = userConfig.googleRefreshToken!;
    
    final credentials = AccessCredentials(
      AccessToken('Bearer', '', DateTime.now().toUtc().subtract(const Duration(hours: 1))),
      refreshToken,
      ['https://www.googleapis.com/auth/gmail.compose'],
    );

    final authClient = autoRefreshingClient(
      ClientId(_clientId, _clientSecret),
      credentials,
      http.Client(),
    );

    try {
      final gmailApi = gmail.GmailApi(authClient);

      final message = gmail.Message()
        ..raw = _createEmail(to, subject, body);

      await gmailApi.users.messages.send(message, 'me');
      session.log('Email sent to $to', level: LogLevel.info);
      return true;
    } catch (e) {
      session.log('Failed to send email: $e', level: LogLevel.error);
      return false;
    } finally {
      authClient.close();
    }
  }

  String _createEmail(String to, String subject, String body) {
    final email = 
      'To: $to\r\n'
      'Subject: $subject\r\n'
      'Content-Type: text/plain; charset=utf-8\r\n\r\n'
      '$body';
    
    return base64Url.encode(utf8.encode(email));
  }
}
