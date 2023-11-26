
import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:shelf/shelf.dart';

import 'bad_request.dart';
import 'handle_request_delete_character.dart';

Future<Response> handleRequestDelete(
    Request request,
    GamestreamFirestore database,
) async {

  final pathSegments = request.requestedUri.pathSegments;

  if (pathSegments.isEmpty) {
    return badRequest('pathSegments.isEmpty');
  }

  final method = pathSegments.first;
  switch (method) {
    case 'character':
      return handleRequestDeleteCharacter(request, database);
    default:
      return badRequest('invalid_post_method: $method');
  }
}
