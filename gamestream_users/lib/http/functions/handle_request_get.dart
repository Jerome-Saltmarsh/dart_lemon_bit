
import 'dart:convert';

import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import '../consts/headers.dart';

Future<Response> handleRequestGet(Request request, Database database) async {
  final pathSegments = request.requestedUri.pathSegments;

  if (pathSegments.length < 2){
    return Response.badRequest();
  }

  final restMethod = pathSegments[pathSegments.length - 2];

  switch (restMethod){
    case 'users':
      return Response(
          200,
          body: jsonEncode(await database.getUser(pathSegments.last)),
          headers: headersAcceptJson
      );
    case 'characters':
      return Response(
          200,
          body: jsonEncode(await database.getCharacter(pathSegments.last)),
          headers: headersAcceptJson
      );
    default:
      return Response.badRequest();

  }
}
