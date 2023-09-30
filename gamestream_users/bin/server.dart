
import 'dart:io';

import 'package:gamestream_users/database/classes/database_firestore.dart';
import 'package:gamestream_users/database/classes/database_local.dart';
import 'package:gamestream_users/http/functions/start_http_server.dart';

const version = 1;
final devMode = Platform.localHostname == "Jerome";

void main(List<String> arguments) async {

  final database = arguments.contains('--local')
      ? DatabaseLocal(path: Directory.current.path)
      : DatabaseFirestore();

  startHttpServer(database: database);
}

