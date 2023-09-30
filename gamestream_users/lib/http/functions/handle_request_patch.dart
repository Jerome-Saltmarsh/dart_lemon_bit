import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import '../../utils/get_body.dart';

Future<Response> handleRequestPatch(Request request, Database database) async {
  final bodyJson = await getBody(request);
  await database.saveCharacter(bodyJson);
  return Response(200);
}
