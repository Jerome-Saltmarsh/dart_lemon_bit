import 'dart:convert';
import 'dart:io';

import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';



Future<Response> handleHttpRequest({
  required Database database,
  required Request request
}) async {

  const headersAcceptJson = {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
    HttpHeaders.accessControlAllowOriginHeader: "*",
    HttpHeaders.accessControlAllowHeadersHeader: "*",
  };

  const headersAcceptText = {
    HttpHeaders.contentTypeHeader: "text/plain",
    HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
    HttpHeaders.accessControlAllowOriginHeader: "*",
    HttpHeaders.accessControlAllowHeadersHeader: "*",
  };


  switch (request.method){
    case 'GET':
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


    case 'POST':
      final requestBody = await getBody(request);

      final userId = requestBody.tryGetString('userId');
      final name = requestBody.tryGetString('name');
      final complexion = requestBody.tryGetInt('complexion');
      final hairType = requestBody.tryGetInt('hairType');
      final hairColor = requestBody.tryGetInt('hairColor');
      final headType = requestBody.tryGetInt('headType');
      final gender = requestBody.tryGetInt('gender');

      if (
          userId == null ||
          name == null ||
          complexion == null ||
          hairType == null ||
          headType == null ||
          gender == null ||
          hairColor == null
      ){
        return Response.badRequest();
      }

      if (name.isEmpty){
        return Response.badRequest(
          headers: headersAcceptText,
          body: 'Name Required',
        );
      }

      await database.createCharacter(
        userId: userId,
        name: name,
        complexion: complexion,
        hairType: hairType,
        hairColor: hairColor,
        headType: headType,
        gender: gender,
      ).catchError((error){
        return Response.internalServerError(
          headers: headersAcceptText,
          body: error.toString(),
        );
      });

      return Response(
          200,
          headers: headersAcceptJson
      );
    case 'OPTIONS':
      return Response(
          200,
          headers: headersAcceptJson
      );
    default:
      return Response.badRequest();
  }


}


Future<Json> getBody(Request request) async {
    return json.decode(await request.readAsString());
}