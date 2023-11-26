import 'dart:convert';

import 'package:gamestream_users/consts/headers.dart';
import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

import '../../utils/get_body.dart';
import 'bad_request.dart';

Future<Response> handleRequestPostLogin(
    Request request,
    GamestreamFirestore database,
) async {

  final requestBody = await getBody(request);
  final username = requestBody.tryGetString('username');
  final password = requestBody.tryGetString('password');

  if (username == null) {
    return badRequest('username_required');
  }

  if (password == null){
    return badRequest('password_required');
  }

  return database
      .findUserByUsernamePassword(username, password)
      .then((userId) => userId == null ?
          Response.notFound('login_failed', headers: headersAcceptText) :
          Response.ok(jsonEncode(userId), headers: headersAcceptText));
}