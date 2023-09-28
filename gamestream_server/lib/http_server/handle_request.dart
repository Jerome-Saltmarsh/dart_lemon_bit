import 'dart:convert';
import 'dart:io';

import 'package:gamestream_server/database/classes/database.dart';
import 'package:shelf/shelf.dart';

Future<Response> handleRequest({
  required Database database,
  required Request request
}) async {
  switch (request.method){
    case 'GET':
      return Response(
        200,
        body: jsonEncode(await database.getUserCharacters('user_01')),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
          HttpHeaders.accessControlAllowOriginHeader: "*",
          HttpHeaders.accessControlAllowHeadersHeader: "*",
        }
      );
  }
  return Response.ok('Hello, regular HTTP server!');
}