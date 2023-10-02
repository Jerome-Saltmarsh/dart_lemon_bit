import 'package:gamestream_users/database/classes/database.dart';
import 'package:gamestream_users/http/consts/headers.dart';
import 'package:gamestream_users/http/functions/bad_request.dart';
import 'package:gamestream_users/utils/get_body.dart';
import 'package:shelf/shelf.dart';

Future<Response> handleRequestPostRegister(Request request, Database database) async {

  final bodyJson = await getBody(request);
  final username = bodyJson['username'];
  final password = bodyJson['password'];

  if (username == null){
    return badRequest('username_required');
  }

  if (password == null){
    return badRequest('password_required');
  }

  final userId = await database.createUser(
      username: username,
      password: password,
  );

  return Response(200, headers: headersAcceptText, body: userId);
}
