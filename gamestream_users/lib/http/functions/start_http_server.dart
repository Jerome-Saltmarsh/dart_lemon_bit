import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'handle_request.dart';

void startHttpServer({
  required Database database,
  required int port,
})  {
  print("startServerHttp(port: $port)");

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((request) => handleRequest(
        database: database,
        request: request,
      ));

  shelf_io.serve(handler, '0.0.0.0', port);
}

