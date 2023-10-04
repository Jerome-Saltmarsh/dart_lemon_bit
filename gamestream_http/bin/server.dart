
import 'package:gamestream_users/functions/start_http_server.dart';
import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';


void main(List<String> arguments) {
  print('main($arguments)');
  print("version 2");

  final database = GamestreamFirestore();

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

