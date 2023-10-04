import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:shelf/shelf.dart';
import '../../utils/get_body.dart';
import 'bad_request.dart';

Future<Response> handleRequestPatch(Request request, GamestreamFirestore database) async {
  final characterJson = await getBody(request);
  final pathSegments = request.url.pathSegments;

  if (pathSegments.isEmpty) {
    return badRequest('pathSegments.isEmpty');
  }

  final userId = request.url.pathSegments.last;
  await database.saveCharacter(userId, characterJson);
  return Response(200);
}
