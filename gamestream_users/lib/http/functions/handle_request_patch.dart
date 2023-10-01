import 'package:gamestream_users/database/classes/database.dart';
import 'package:gamestream_users/http/functions/bad_request.dart';
import 'package:shelf/shelf.dart';
import '../../utils/get_body.dart';

Future<Response> handleRequestPatch(Request request, Database database) async {
  final characterJson = await getBody(request);
  final pathSegments = request.url.pathSegments;

  if (pathSegments.isEmpty) {
    return badRequest('pathSegments.isEmpty');
  }

  final userId = request.url.pathSegments.last;
  await database.saveCharacter(userId, characterJson);
  return Response(200);
}
