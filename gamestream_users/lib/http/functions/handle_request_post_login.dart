import 'dart:convert';

import 'package:gamestream_users/database/classes/database.dart';
import 'package:gamestream_users/http/consts/headers.dart';
import 'package:gamestream_users/http/functions/bad_request.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

import '../../utils/get_body.dart';

Future<Response> handleRequestPostLogin(Request request, Database database) async {
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
      .then((user) => user == null ?
          Response.notFound('login_failed', headers: headersAcceptText) :
          Response.ok(jsonEncode(user), headers: headersAcceptJson));
}