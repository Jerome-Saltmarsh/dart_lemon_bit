import 'package:gamestream_users/consts/headers.dart';
import 'package:gamestream_users/consts/user_validation.dart';
import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:gamestream_users/utils/get_body.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

import 'bad_request.dart';
import 'is_valid_password.dart';

Future<Response> handleRequestPostRegister(
    Request request,
    GamestreamFirestore database,
) async {

  final bodyJson = await getBody(request);
  final username = bodyJson.tryGetString('username')?.trim();
  final password = bodyJson.tryGetString('password')?.trim();

  if (username == null){
    return badRequest('username_required');
  }

  if (password == null){
    return badRequest('password_required');
  }

  for (final entry in usernameRules.entries){
    if (!entry.key.hasMatch(username)){
      return Response(422,
          headers: headersAcceptText,
          body: 'Invalid Username - ${entry.value}'
      );
    }
  }

  if (!isValidPassword(password)){
    return Response(422,
        headers: headersAcceptText,
        body: 'Invalid Password - Requires at least 8 characters, including at '
            'least one uppercase letter one lowercase letter, and one digit.'
    );
  }

  final existingUser = await database.findUserByUsername(username);

  if (existingUser != null) {
    return Response(
        409,
        headers: headersAcceptText,
        body: 'A user with that username already exists',
    );
  }

  final userId = await database.createUser(
      username: username,
      password: password,
  );

  return Response(200, headers: headersAcceptText, body: userId);
}
