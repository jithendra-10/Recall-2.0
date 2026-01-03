import 'package:recall_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

// Run with: dart bin/reset_sync.dart

Future<void> main(List<String> args) async {
  final client = Client(
    'http://localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  );

  // We have to use a direct DB connection or proper server-side script,
  // but since we can't easily run a server script from outside, 
  // we'll use a hack: create a temporary endpoint or just restart the server 
  // and modify DashboardEndpoint to force-reset on next load.
  
  // Actually, easiest way is to use the `run_command` to execute a script 
  // that imports serverpod and runs the DB update.
}
