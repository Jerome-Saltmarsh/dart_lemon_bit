import 'dart:convert';
import 'dart:io';

import 'package:gamestream_server/database/database.dart';
import 'package:shelf/shelf.dart';

Future<Response> handleRequest({
  required Database database,
  required Request request
}) async {
  switch (request.method){
    case 'GET':
      final body = {
        'characters': await database.getUserCharacters('test')
      };

      return Response(
        200,
        body: jsonEncode(body),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          // HttpHeaders.contentTypeHeader: "text/plain; charset=UTF-8",
          HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
          HttpHeaders.accessControlAllowOriginHeader: "*",
          HttpHeaders.accessControlAllowHeadersHeader: "*",
        }
      );
  }
  return Response.ok('Hello, regular HTTP server!');
}