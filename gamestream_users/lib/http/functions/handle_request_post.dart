import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import 'bad_request.dart';
import 'handle_request_post_character.dart';
import 'handle_request_post_user.dart';

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
    case 'users':
      return await handleRequestPostUser(request, database);
    case 'characters':
      return await handleRequestPostCharacter(request, database);
    default:
      return badRequest('invalid_post_method: $method');
  }
}


