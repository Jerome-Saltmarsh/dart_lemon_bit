import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'handle_request.dart';

void startHttpServer({
  required GamestreamFirestore database,
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

