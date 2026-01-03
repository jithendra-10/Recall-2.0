
import 'package:recall_server/server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:recall_server/src/future_calls/gmail_sync_future_call.dart';
import 'dart:io';

void main() async {
  // This is a hacky way to run a sync manually for testing
  // We need a session, which requires a started serverpod.
  // Instead, let's just use the server's bin/main.dart logic or similar.
  print('Manual sync trigger not easily possible without full serverpod context.');
}
