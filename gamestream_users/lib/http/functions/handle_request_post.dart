import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import 'bad_request.dart';
import 'handle_request_post_character.dart';
import 'handle_request_post_login.dart';
import 'handle_request_post_register.dart';

Future<Response> handleRequestPost(
  Request request,
  Database database,
) async {

  final pathSegments = request.requestedUri.pathSegments;

  if (pathSegments.isEmpty) {
    return badRequest('arguments_required');
  }

  final method = pathSegments.first;
  switch (method) {
    case 'character':
      return await handleRequestPostCharacter(request, database);
    case 'login':
      return await handleRequestPostLogin(request, database);
    case 'register':
      return await handleRequestPostRegister(request, database);
    default:
      return badRequest('invalid_post_method: $method');
  }
}


