import 'dart:io';

import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'handle_request.dart';

Future<HttpServer> startHttpServer({
  required Database database,
  int port = 8082,
}) async {
  print("startServerHttp(port: $port)");
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((request) => handleRequest(
        database: database,
        request: request,
      ));

  return await shelf_io.serve(handler, '0.0.0.0', port);
}

