
import 'dart:io';

import 'package:gamestream_users/database/classes/database_firestore.dart';
import 'package:gamestream_users/database/classes/database_local.dart';
import 'package:gamestream_users/http/functions/start_http_server.dart';

void main(List<String> arguments) {
  print('main($arguments)');

  final database = arguments.contains('--local')
      ? DatabaseLocal(path: Directory.current.path)
      : DatabaseFirestore();

  final int port;

  final portIndex = arguments.indexOf('--port');
  if (portIndex == -1){
    port = 8080;
  } else {
    if (portIndex >= arguments.length) {
      print('port value required');
      return;
    }

    final tryPort = int.tryParse(arguments[portIndex + 1]);
    if (tryPort == null) {
      print('invalid port value');
      return;
    }
    port = tryPort;
  }

  startHttpServer(
      database: database,
      port: port,
  );
}

