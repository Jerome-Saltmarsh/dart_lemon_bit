import 'dart:io';

import 'package:shelf/shelf.dart';

Response handleRequest(Request request) {
  switch (request.method){
    case 'GET':
      return Response(
        200,
        body: 'hello world',
        headers: {
          HttpHeaders.contentTypeHeader: "text/plain; charset=UTF-8",
          HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
          HttpHeaders.accessControlAllowOriginHeader: "*",
          HttpHeaders.accessControlAllowHeadersHeader: "*",
        }
      );
  }
  return Response.ok('Hello, regular HTTP server!');
}